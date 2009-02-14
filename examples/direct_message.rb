#!/usr/bin/env ruby

require 'rubygems'
require 'rubytter'

if ARGV.size < 3
  puts "Usage: ruby #{File.basename(__FILE__)} user_id password id message"
  exit
end

client = Rubytter.new(ARGV[0], ARGV[1])
p client.direct_message(ARGV[2], ARGV[3])
