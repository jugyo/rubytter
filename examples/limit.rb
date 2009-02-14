#!/usr/bin/env ruby

require 'rubygems'
require 'rubytter'
require 'time'

if ARGV.size < 2
  puts "Usage: ruby #{File.basename(__FILE__)} user_id password"
  exit
end

client = Rubytter.new(ARGV[0], ARGV[1])
limit_status = client.limit_status
puts <<EOS
 reset_time_in_seconds: #{limit_status.reset_time_in_seconds}
        remaining_hits: #{limit_status.remaining_hits}
          hourly_limit: #{limit_status.hourly_limit}
            reset_time: #{Time.parse(limit_status.reset_time).strftime('%Y/%m/%d %X')}
EOS
