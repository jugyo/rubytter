# -*- coding: utf-8 -*-
require 'rubygems'
require 'json'
require 'net/https'
require 'cgi'

require 'oauth'
require 'rubytter/core_ext'
require 'rubytter/connection'
require 'rubytter/oauth'
require 'rubytter/oauth_rubytter'

class Rubytter
  VERSION = File.read(File.join(File.dirname(__FILE__), '../VERSION')).strip

  class APIError < StandardError
    attr_reader :response
    def initialize(msg, response = nil)
      super(msg)
      @response = response
    end
  end

  attr_reader :login
  attr_accessor :host, :header, :path_prefix

  def initialize(login = nil, password = nil, options = {})
    @login = login
    @password = password
    setup(options)
  end

  def setup(options)
    @host = options[:host] || 'api.twitter.com'
    @search_host = options[:search_host] || 'search.twitter.com'
    @header = {'User-Agent' => "Rubytter/#{VERSION} (http://github.com/jugyo/rubytter)"}
    @header.merge!(options[:header]) if options[:header]
    @app_name = options[:app_name]
    @connection = Connection.new(options)
    @connection_for_search = Connection.new(options.merge({:enable_ssl => false}))
    @path_prefix = options[:path_prefix] || '/1.1'
  end

  def self.api_settings
    # method name             path for API                    http method
    "
      update_status           /statuses/update                post
      remove_status           /statuses/destroy/%s            post
      #public_timeline         /statuses/public_timeline
      home_timeline           /statuses/home_timeline
      friends_timeline        /statuses/friends_timeline
      #replies                 /statuses/replies
      mentions                /statuses/mentions_timeline
      user_timeline           /statuses/user_timeline
      show                    /statuses/show/%s
      friends                 /friends/list
      followers               /followers/list
      retweet                 /statuses/retweet/%s            post
      retweets                /statuses/retweets/%s
      #retweeted_by_me         /statuses/retweeted_by_me
      #retweeted_to_me         /statuses/retweeted_to_me
      retweets_of_me          /statuses/retweets_of_me
      user                    /users/show
      direct_messages         /direct_messages
      sent_direct_messages    /direct_messages/sent
      send_direct_message     /direct_messages/new            post
      remove_direct_message   /direct_messages/destroy        post
      follow                  /friendships/create             post
      leave                   /friendships/destroy            post
      friendship_exists       /friendships/show
      followers_ids           /followers/ids
      friends_ids             /friends/ids
      favorites               /favorites/list
      favorite                /favorites/create               post
      remove_favorite         /favorites/destroy              post
      verify_credentials      /account/verify_credentials     get
      #end_session             /account/end_session            post
      update_delivery_device  /account/update_delivery_device post
      update_profile_colors   /account/update_profile_colors  post
      limit_status            /application/rate_limit_status
      update_profile          /account/update_profile         post
      #enable_notification     /notifications/follow/%s        post
      #disable_notification    /notifications/leave/%s         post
      block                   /blocks/create                  post
      unblock                 /blocks/destroy                 post
      blocking                /blocks/list                    get
      blocking_ids            /blocks/ids                     get
      saved_searches          /saved_searches/list            get
      saved_search            /saved_searches/show/%s         get
      create_saved_search     /saved_searches/create          post
      remove_saved_search     /saved_searches/destroy/%s      post
      create_list             /lists/create                   post
      update_list             /lists/update                   post
      delete_list             /lists/destroy                  post
      list                    /lists/show
      lists                   /lists/list
      lists_followers         /lists/memberships
      list_statuses           /lists/statuses
      list_members            /lists/members
      add_member_to_list      /lists/members/create           post
      remove_member_from_list /lists/members/destroy          post
      list_following          /lists/subscribers
      follow_list             /lists/subscribers/create       post
      remove_list             /lists/subscribers/destroy      post
    ".strip.split("\n").map{|line| line.strip.split(/\s+/)}
  end

  api_settings.each do |array|
    method, path, http_method = *array
    http_method ||= 'get'
    method.sub!(/^#/, '') and obsoleted = true
    if obsoleted
      eval <<-EOS
        def #{method}(*args)
          raise APIError.new('#{method} is obsoleted.')
        end
      EOS
    elsif /%s/ =~ path
      eval <<-EOS
        def #{method}(*args)
          params = args.last.kind_of?(Hash) ? args.pop : {}
          path = '#{path}' % args
          path.sub!(/\\/\\z/, '')
          #{http_method}(path, params)
        end
      EOS
    else
      eval <<-EOS
        def #{method}(params = {})
          #{http_method}('#{path}', params)
        end
      EOS
    end
  end

  alias_method :__update_status, :update_status
  def update_status(params = {})
    params[:source] = @app_name if @app_name
    __update_status(params)
  end

  alias_method :__create_saved_search, :create_saved_search
  def create_saved_search(arg)
    arg = {:query => arg} if arg.kind_of?(String)
    __create_saved_search(arg)
  end

  def update(status, params = {})
    update_status(params.merge({:status => status}))
  end

  def direct_message(user, text, params = {})
    send_direct_message(params.merge({:user => user, :text => text}))
  end

  def get(path, params = {})
    path += '.json'
    param_str = '?' + to_param_str(params)
    path = path + param_str unless param_str.empty?
    req = create_request(Net::HTTP::Get.new(path_prefix + path))
    structize(http_request(@host, req))
  end

  def post(path, params = {})
    path += '.json'
    param_str = to_param_str(params)
    req = create_request(Net::HTTP::Post.new(path_prefix + path))
    structize(http_request(@host, req, param_str))
  end

  def delete(path, params = {})
    path += '.json'
    param_str = to_param_str(params)
    req = create_request(Net::HTTP::Delete.new(path_prefix + path))
    structize(http_request(@host, req, param_str))
  end

  def search(query, params = {})
    path = '/search.json'
    param_str = '?' + to_param_str(params.merge({:q => query}))
    path = path + param_str unless param_str.empty?
    req = create_request(Net::HTTP::Get.new(path), false)

    json_data = http_request("#{@search_host}", req, nil, @connection_for_search)
    structize(
      json_data['results'].map do |result|
        search_result_to_hash(result)
      end
    )
  end

  def search_user(query, params = {})
    path = '/users/search.json'
    param_str = '?' + to_param_str(params.merge({:q => query}))
    path = path + param_str unless param_str.empty?
    req = create_request(Net::HTTP::Get.new(path_prefix + path))
    structize(http_request(@host, req))
  end

  def search_result_to_hash(json)
    {
      'id' => json['id'],
      'text' => json['text'],
      'source' => json['source'],
      'created_at' => json['created_at'],
      'in_reply_to_user_id' => json['to_user_id'],
      'in_reply_to_screen_name' => json['to_user'],
      'in_reply_to_status_id' => nil,
      'user' => {
        'id' => json['from_user_id'],
        'name' => nil,
        'screen_name' => json['from_user'],
        'profile_image_url' => json['profile_image_url']
      }
    }
  end

  def http_request(host, req, param_str = nil, connection = nil)
    connection ||= @connection
    res = connection.start(host) do |http|
      if param_str
        http.request(req, param_str)
      else
        http.request(req)
      end
    end
    json_data = JSON.parse(res.body)
    case res.code
    when "200"
      json_data
    else
      raise APIError.new(json_data['error'], res)
    end
  end

  def create_request(req, basic_auth = true)
    @header.each {|k, v| req.add_field(k, v) }
    req.basic_auth(@login, @password) if basic_auth
    req
  end

  def structize(data)
    case data
    when Array
      data.map{|i| structize(i)}
    when Hash
      class << data
        def id
          self[:id]
        end

        def to_hash(obj = self)
          obj.inject({}) {|memo, (key, value)|
            memo[key] = (value.kind_of? obj.class) ? to_hash(value) : value
            memo
          }
        end

        def method_missing(name, *args)
          self[name]
        end
      end

      data.keys.each do |k|
        case k
        when String, Symbol # String しかまず来ないだろうからこの判定はいらない気もするなぁ
          data[k] = structize(data[k])
        else
          data.delete(k)
        end
      end

      data.symbolize_keys!
    else
      case data
      when String
        CGI.unescapeHTML(data) # ここで unescapeHTML すべきか悩むところではある
      else
        data
      end
    end
  end

  def to_param_str(hash)
    raise ArgumentError, 'Argument must be a Hash object' unless hash.is_a?(Hash)
    hash.to_a.map{|i| i[0].to_s + '=' + CGI.escape(i[1].to_s) }.join('&')
  end
end
