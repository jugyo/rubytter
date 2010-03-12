$:.unshift File.join(File.dirname(__FILE__), '../lib')
require 'rubygems'
require 'rubytter'

key = ""
secret = ""

oauth = Rubytter::OAuth.new(key, secret)

request_token = oauth.get_request_token
system('open', request_token.authorize_url) || puts("Access here: #{request_token.authorize_url}\nand...")

print "Enter PIN: "
pin = gets.strip

access_token = request_token.get_access_token(
  :oauth_token => request_token.token,
  :oauth_verifier => pin
)

client = OAuthRubytter.new(access_token)
client.friends_timeline.each do |status|
  puts "#{status.user.screen_name}: #{status.text}"
end
