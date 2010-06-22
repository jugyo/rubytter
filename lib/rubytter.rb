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
  attr_accessor :host, :header

  def initialize(login = nil, password = nil, options = {})
    @login = login
    @password = password
    setup(options)
  end

  def setup(options)
    @host = options[:host] || 'api.twitter.com'
    @header = {'User-Agent' => "Rubytter/#{VERSION} (http://github.com/jugyo/rubytter)"}
    @header.merge!(options[:header]) if options[:header]
    @app_name = options[:app_name]
    @connection = Connection.new(options)
    @connection_for_search = Connection.new(options.merge({:enable_ssl => false}))
  end

  def self.api_settings
    # method name             path for API                    http method
    "
      update_status           /1/statuses/update                post
      remove_status           /1/statuses/destroy/%s            delete
      public_timeline         /1/statuses/public_timeline
      home_timeline           /1/statuses/home_timeline
      friends_timeline        /1/statuses/friends_timeline
      replies                 /1/statuses/replies
      mentions                /1/statuses/mentions
      user_timeline           /1/statuses/user_timeline/%s
      show                    /1/statuses/show/%s
      friends                 /1/statuses/friends/%s
      followers               /1/statuses/followers/%s
      retweet                 /1/statuses/retweet/%s            post
      retweets                /1/statuses/retweets/%s
      retweeted_by_me         /1/statuses/retweeted_by_me
      retweeted_to_me         /1/statuses/retweeted_to_me
      retweets_of_me          /1/statuses/retweets_of_me
      user                    /1/users/show/%s
      direct_messages         /1/direct_messages
      sent_direct_messages    /1/direct_messages/sent
      send_direct_message     /1/direct_messages/new            post
      remove_direct_message   /1/direct_messages/destroy/%s     delete
      follow                  /1/friendships/create/%s          post
      leave                   /1/friendships/destroy/%s         delete
      friendship_exists       /1/friendships/exists
      followers_ids           /1/followers/ids/%s
      friends_ids             /1/friends/ids/%s
      favorites               /1/favorites/%s
      favorite                /1/favorites/create/%s            post
      remove_favorite         /1/favorites/destroy/%s           delete
      verify_credentials      /1/account/verify_credentials     get
      end_session             /1/account/end_session            post
      update_delivery_device  /1/account/update_delivery_device post
      update_profile_colors   /1/account/update_profile_colors  post
      limit_status            /1/account/rate_limit_status
      update_profile          /1/account/update_profile         post
      enable_notification     /1/notifications/follow/%s        post
      disable_notification    /1/notifications/leave/%s         post
      block                   /1/blocks/create/%s               post
      unblock                 /1/blocks/destroy/%s              delete
      block_exists            /1/blocks/exists/%s               get
      blocking                /1/blocks/blocking                get
      blocking_ids            /1/blocks/blocking/ids            get
      saved_searches          /1/saved_searches                 get
      saved_search            /1/saved_searches/show/%s         get
      create_saved_search     /1/saved_searches/create          post
      remove_saved_search     /1/saved_searches/destroy/%s      delete
      create_list             /1/:user/lists                    post
      update_list             /1/:user/lists/%s                 put
      delete_list             /1/:user/lists/%s                 delete
      lists                   /1/%s/lists
      lists_followers         /1/%s/lists/memberships
      list_statuses           /1/%s/lists/%s/statuses
      list                    /1/%s/lists/%s
      list_members            /1/%s/%s/members
      add_member_to_list      /1/:user/%s/members               post
      remove_member_from_list /1/:user/%s/members               delete
      list_following          /1/%s/%s/subscribers
      follow_list             /1/%s/%s/subscribers              post
      remove_list             /1/%s/%s/subscribers              delete
    ".strip.split("\n").map{|line| line.strip.split(/\s+/)}
  end

  api_settings.each do |array|
    method, path, http_method = *array
    http_method ||= 'get'
    if /%s/ =~ path
      eval <<-EOS
        def #{method}(*args)
          path = login ? '#{path}'.gsub(':user', login) :'#{path}'
          params = args.last.kind_of?(Hash) ? args.pop : {}
          path = path % args
          path.sub!(/\\/\\z/, '')
          #{http_method}(path, params)
        end
      EOS
    else
      eval <<-EOS
        def #{method}(params = {})
          path = login ? '#{path}'.gsub(':user', login) :'#{path}'
          #{http_method}(path, params)
        end
      EOS
    end
  end

  alias_method :__create_list, :create_list
  def create_list(name, params = {})
    __create_list(params.merge({:name => name}))
  end

  alias_method :__add_member_to_list, :add_member_to_list
  def add_member_to_list(list_slug, user_id, params = {})
    __add_member_to_list(list_slug, params.merge({:id => user_id}))
  end

  alias_method :__remove_member_from_list, :remove_member_from_list
  def remove_member_from_list(list_slug, user_id, params = {})
    __remove_member_from_list(list_slug, params.merge({:id => user_id}))
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
    req = create_request(Net::HTTP::Get.new(path))
    structize(http_request(@host, req))
  end

  def post(path, params = {})
    path += '.json'
    param_str = to_param_str(params)
    req = create_request(Net::HTTP::Post.new(path))
    structize(http_request(@host, req, param_str))
  end

  def delete(path, params = {})
    path += '.json'
    param_str = to_param_str(params)
    req = create_request(Net::HTTP::Delete.new(path))
    structize(http_request(@host, req, param_str))
  end

  def search(query, params = {})
    path = '/search.json'
    param_str = '?' + to_param_str(params.merge({:q => query}))
    path = path + param_str unless param_str.empty?
    req = create_request(Net::HTTP::Get.new(path), false)

    json_data = http_request("#{@host}", req, nil, @connection_for_search)
    structize(
      json_data['results'].map do |result|
        search_result_to_hash(result)
      end
    )
  end

  def search_user(query, params = {})
    path = '/1/users/search.json'
    param_str = '?' + to_param_str(params.merge({:q => query}))
    path = path + param_str unless param_str.empty?
    req = create_request(Net::HTTP::Get.new(path))
    structize(http_request(@host, req))
  end

  def search_result_to_hash(json)
    {
      'id' => json['id'],
      'text' => json['text'],
      'source' => json['source'],
      'created_at' => json['created_at'],
      'in_reply_to_user_id' => json['to_usre_id'],
      'in_reply_to_screen_name' => json['to_usre'],
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
