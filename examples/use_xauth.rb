$:.unshift File.join(File.dirname(__FILE__), '../lib')
require 'rubygems'
require 'rubytter'

key = ''
secret = ''
login = ''
password = ''

oauth = Rubytter::OAuth.new(key, secret)
access_token = oauth.get_access_token_with_xauth(login, password)

client = OAuthRubytter.new(access_token)
client.friends_timeline.each do |status|
  puts "#{status.user.screen_name}: #{status.text}"
end
