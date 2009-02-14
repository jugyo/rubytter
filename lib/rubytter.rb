require 'rubygems'
require 'json'
require 'net/https'
require 'cgi'

require 'rubytter/connection'

class Rubytter
  APP_NAME = 'Rubytter'
  VERSION = '0.4.0'
  HOMEPAGE = 'http://github.com/jugyo/rubytter'

  def initialize(login, password, options = {})
    @login = login
    @password = password
    @host = options[:host] || 'twitter.com'
    @connection = Connection.new(options)
  end

  def self.api_settings
    # method name             path for API                    http method
    "
      update_status           /statuses/update                post
      remove_status           /statuses/destroy/%s            delete
      public_timeline         /statuses/public_timeline
      friends_timeline        /statuses/friends_timeline
      replies                 /statuses/replies
      user_timeline           /statuses/user_timeline/%s
      show                    /statuses/show/%s
      friends                 /statuses/friends/%s
      followers               /statuses/followers/%s
      user                    /users/show/%s
      direct_messages         /direct_messages
      sent_direct_messages    /direct_messages/sent
      send_direct_message     /direct_messages/new            post
      remove_direct_message   /direct_messages/destroy/%s     delete
      follow                  /friendships/create/%s          post
      leave                   /friendships/destroy/%s         delete
      friendship_exists       /friendships/exists
      followers_ids           /followers/ids/%s
      friends_ids             /friends/ids/%s
      favorites               /favorites
      favorite                /favorites/create/%s            post
      remove_favorite         /favorites/destroy/%s           delete
      verify_credentials      /account/verify_credentials     get
      end_session             /account/end_session            post
      update_delivery_device  /account/update_delivery_device post
      update_profile_colors   /account/update_profile_colors  post
      limit_status            /account/rate_limit_status
      update_profile          /account/update_profile         post
      enable_notification     /notifications/follow/%s        post
      disable_notification    /notifications/leave/%s         post
      block                   /blocks/create/%s               post
      unblock                 /blocks/destroy/%s              delete
    ".strip.split("\n").map{|line| line.strip.split(/\s+/)}
  end

  api_settings.each do |array|
    method, path, http_method = *array
    http_method ||= 'get'
    if /%s$/ =~ path
      eval <<-EOS
        def #{method}(id, params = {})
          #{http_method}('#{path}' % id, params)
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

  def update(status, params = {})
    update_status(params.merge({:status => status}))
  end

  def direct_message(user, text, params = {})
    send_direct_message(params.merge({:user => user, :text => text}))
  end

  def get(path, params = {})
    path += '.json'
    param_str = '?' + params.to_a.map{|i| i[0].to_s + '=' + CGI.escape(i[1].to_s) }.join('&')
    path = path + param_str unless param_str.empty?
    req = prepare_request(Net::HTTP::Get.new(path))
    res_body = @connection.start(@host) do |http|
      http.request(req).body
    end
    json_to_struct(JSON.parse(res_body))
  end

  def post(path, params = {})
    path += '.json'
    param_str = params.to_a.map{|i| i[0].to_s + '=' + CGI.escape(i[1].to_s) }.join('&')
    req = prepare_request(Net::HTTP::Post.new(path))
    res_body = @connection.start(@host) do |http|
      http.request(req, param_str).body
    end
    json_to_struct(JSON.parse(res_body))
  end

  alias delete post

  def prepare_request(req)
    req.add_field('User-Agent', "#{APP_NAME} #{HOMEPAGE}")
    req.basic_auth(@login, @password)
    return req
  end

  def json_to_struct(json)
    case json
    when Array
      json.map{|i| json_to_struct(i)}
    when Hash
      struct_values = {}
      json.each do |k, v|
        case k
        when String, Symbol
          struct_values[k.to_sym] = json_to_struct(v)
        end
      end
      unless struct_values.empty?
        Struct.new(*struct_values.keys).new(*struct_values.values)
      else
        nil
      end
    else
      json
    end
  end
end
