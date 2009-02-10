require 'rubygems'
require 'json'
require 'net/https'
require 'cgi'

class Rubytter
  APP_NAME = self.to_s

  def initialize(login, password, options = {})
    @login = login
    @password = password
    # TODO: for proxy
    @host = options[:host] || 'twitter.com'
    @connection = Connection.new(options)
  end

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

  alias delete post

  %w(
    /statuses/user_timeline/%s
    /statuses/show/%s
    /statuses/friends/%s
    /statuses/followers/%s
  ).each do |path|
    method_name = path.sub('/statuses/', '').sub('/%s', '')
    eval <<-EOS
      def #{method_name}(id, params = {})
        get('#{path}' % id, params)
      end
    EOS
  end

  %w(
    /statuses/public_timeline
    /statuses/friends_timeline
    /statuses/replies
  ).each do |path|
    method_name = path.sub('/statuses/', '')
    eval <<-EOS
      def #{method_name}(params = {})
        get('#{path}', params)
      end
    EOS
  end

  %w(
    /statuses/destroy/%s
  ).each do |path|
    method_name = path.sub('/statuses/', '').sub('/%s', '')
    eval <<-EOS
      def #{method_name}(id, params = {})
        delete('#{path}' % id, params)
      end
    EOS
  end

  def update(status, params = {})
    post('/statuses/update', params.merge({:status => status}))
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
