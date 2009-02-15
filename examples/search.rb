#!/usr/bin/env ruby

require 'rubygems'
require 'rubytter'

if ARGV.size < 2
  puts "Usage: ruby #{File.basename(__FILE__)} user_id password"
  exit
end

client = Rubytter.new(ARGV[0], ARGV[1])
client.search('ruby').results.each do |status|
  puts "#{status.from_user}: #{status.text}"
end
