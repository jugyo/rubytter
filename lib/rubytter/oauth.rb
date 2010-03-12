class Rubytter
  class OAuth
    def initialize(key, secret, ca_file = nil)
      @key = key
      @secret = secret
      @ca_file = ca_file
    end

    def get_access_token_with_xauth(login, password)
      consumer = create_consumer
      consumer.get_access_token(nil, {}, {
        :x_auth_mode => "client_auth",
        :x_auth_username => login,
        :x_auth_password => password
      })
    end

    def get_request_token
      create_consumer.get_request_token
    end

    def create_consumer
      if @ca_file
        consumer = ::OAuth::Consumer.new(@key, @secret,
          :site => 'https://api.twitter.com', :ca_file => @ca_file)
      else
        consumer = ::OAuth::Consumer.new(@key, @secret,
          :site => 'https://api.twitter.com')
        consumer.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      consumer
    end
  end
end
