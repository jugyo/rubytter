require 'rubygems'
require 'json'
require 'net/https'
require 'cgi'

require 'rubytter/connection'

class Hash
  def to_struct
    struct_values = []
    each do |k, v|
      struct_values << (v.is_a?(Hash) ? v.to_struct : v)
    end
    Struct.new(*keys.map{|k|k.to_sym}).new(*struct_values)
  end
end

class Rubytter
  APP_NAME = self.to_s

  def initialize(login, password, options = {})
    @login = login
    @password = password
    @host = options[:host] || 'twitter.com'
    @connection = Connection.new(options)
  end

  def self.api_settings
    # method name             path for API                 http method
    "
      status_update           /statuses/update             post
      destroy                 /statuses/destroy/%s         delete
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
      send_direct_message     /direct_messages/new         post
      destroy_direct_message  /direct_messages/destroy/%s  delete
      create_friendship       /friendships/create/%s       post
      destroy_friendship      /friendships/destroy/%s      delete
      friendship_exists       /friendships/exists
      followers_ids           /followers/ids/%s
      friends_ids             /friends/ids/%s
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
    status_update(params.merge({:status => status}))
  end

  def direct_message(user, text, params = {})
    send_direct_message(params.merge({:user => user, :text => text}))
  end

  # TODO: define some alias for commonly　used　methods

  def get(path, params = {})
    path += '.json'
    param_str = '?' + params.to_a.map{|i| i[0].to_s + '=' + CGI.escape(i[1]) }.join('&')
    path = path + param_str unless param_str.empty?
    req = prepare_request(Net::HTTP::Get.new(path))
    res_text = @connection.start(@host) do |http|
      http.request(req).body
    end
    json = JSON.parse(res_text)
    return  case json
            when Array
              json.map do |i|
                if i.is_a?(Hash)
                  i.to_struct
                else
                  i
                end
              end
            when Hash
              json.to_struct
            else
              json
            end
  end

  def post(path, params = {})
    path += '.json'
    param_str = params.to_a.map{|i| i[0].to_s + '=' + CGI.escape(i[1]) }.join('&')
    req = prepare_request(Net::HTTP::Post.new(path))
    @connection.start(@host) do |http|
      http.request(req, param_str).body
    end
  end

  def delete(path, params = {})
    post(path, params)
  end

  def prepare_request(req)
    req.add_field('User-Agent', 'Rubytter http://github.com/jugyo/rubytter')
    req.basic_auth(@login, @password)
    return req
  end
end
