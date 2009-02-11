require 'rubygems'
require 'json'
require 'net/https'
require 'cgi'

class Rubytter
  APP_NAME = self.to_s

  def initialize(login, password, options = {})
    @login = login
    @password = password
    @host = options[:host] || 'twitter.com'
    @connection = Connection.new(options)
  end

  [
    ['status_update',           '/statuses/update',             'post'],
    ['destroy',                 '/statuses/destroy/%s',         'delete'],
    ['public_timeline',         '/statuses/public_timeline'],
    ['friends_timeline',        '/statuses/friends_timeline'],
    ['replies',                 '/statuses/replies'],
    ['user_timeline',           '/statuses/user_timeline/%s'],
    ['show',                    '/statuses/show/%s'],
    ['friends',                 '/statuses/friends/%s'],
    ['followers',               '/statuses/followers/%s'],
    ['user',                    '/users/show/%s'],
    ['direct_messages',         '/direct_messages'],
    ['sent_direct_messages',    '/direct_messages/sent'],
    ['send_direct_message',     '/direct_messages/new',         'post'],
    ['destroy_direct_message',  '/direct_messages/destroy/%s',  'delete'],
    ['create_friendship',       '/friendships/create/%s',       'post'],
    ['destroy_friendship',      '/friendships/destroy/%s',      'delete'],
    ['friendship_exists',       '/friendships/exists'],
    ['followers_ids',           '/followers/ids/%s'],
    ['friends_ids',             '/friends/ids/%s'],
  ].each do |array|
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

    req = Net::HTTP::Get.new(path)
    req.add_field('User-Agent', 'Rubytter http://github.com/jugyo/rubytter')
    req.basic_auth(@login, @password)
    res_text = @connection.start(@host) do |http|
      http.request(req).body
    end
    return JSON.parse(res_text)
  end

  def post(path, params = {})
    path += '.json'
    param_str = params.to_a.map{|i| i[0].to_s + '=' + CGI.escape(i[1]) }.join('&')

    req = Net::HTTP::Post.new(path)
    req.add_field('User-Agent', 'Rubytter http://github.com/jugyo/rubytter')
    req.basic_auth(@login, @password)
    @connection.start(@host) do |http|
      http.request(req, param_str).body
    end
  end

  def delete(path, params = {})
    post(path, params)
  end

  class Connection
    attr_reader :protocol, :port, :proxy_uri

    def initialize(options = {})
      @proxy_host = options[:proxy_host]
      @proxy_port = options[:proxy_port]
      @proxy_user = options[:proxy_user_name]
      @proxy_password = options[:proxy_password]
      @proxy_uri = nil
      @enable_ssl = options[:enable_ssl]

      if @proxy_host
        @http_class = Net::HTTP::Proxy(@proxy_host, @proxy_port,
                                       @proxy_user, @proxy_password)
        @proxy_uri =  "http://" + @proxy_host + ":" + @proxy_port + "/"
      else
        @http_class = Net::HTTP
      end

      if @enable_ssl
        @protocol = "https"
        @port = 443
      else
        @protocol = "http"
        @port = 80
      end
    end

    def start(host, port = nil, &block)
      http = @http_class.new(host, port || @port)
      http.use_ssl = @enable_ssl
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?
      http.start(&block)
    end
  end
end
