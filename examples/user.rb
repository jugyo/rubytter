#!/usr/bin/env ruby

require 'rubygems'
require 'rubytter'
require 'time'

if ARGV.size < 3
  puts "Usage: ruby #{File.basename(__FILE__)} user_id password id"
  exit
end

client = Rubytter.new(ARGV[0], ARGV[1])
user = client.user(ARGV[2])

puts <<EOS
            id: #{user.id}
          name: #{user.name}
   screen_name: #{user.screen_name}
           url: #{user.url}
   description: #{user.description}
     followers: #{user.followers_count}
    followings: #{user.friends_count}
     time_zone: #{user.time_zone}
      location: #{user.location}
    created_at: #{Time.parse(user.created_at).strftime('%Y/%m/%d %X')}
EOS
