class Rubytter
  module XAuth
    def self.init(config)
      @@key = config[:key]
      @@secret = config[:secret]
      @@ca_file = config[:ca_file]
    end

    def self.get_access_token(login, password)
      if @@ca_file
        consumer = OAuth::Consumer.new(@@key, @@secret,
          :site => 'https://api.twitter.com', :ca_file => @@ca_file)
      else
        consumer = OAuth::Consumer.new(@@key, @@secret,
          :site => 'https://api.twitter.com')
        consumer.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      consumer.get_access_token(nil, {}, {
        :x_auth_mode => "client_auth",
        :x_auth_username => login,
        :x_auth_password => password,
      })
    end
  end
end
