$:.unshift File.join(File.dirname(__FILE__), '../lib')
require 'rubygems'
require 'rubytter'

XAuthRubytter.init(
  :key => 'CONSUMER-KEY',
  :secret => 'CONSUMER-SECRET'
)

# # OR
# XAuthRubytter.init(
#   :key => 'CONSUMER-KEY',
#   :secret => 'CONSUMER-SECRET',
#   :ca_file => 'PATH-TO-CA_FILE'
# )

client = XAuthRubytter.new('LOGIN', 'PASSWORD')
p client.access_token.token
p client.access_token.secret

client.friends_timeline.each do |status|
  puts "#{status.user.screen_name}: #{status.text}"
end
