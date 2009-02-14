#!/usr/bin/env ruby

require 'rubygems'
require 'rubytter'

if ARGV.size < 3
  puts "Usage: ruby #{File.basename(__FILE__)} user_id password text"
  exit
end

client = Rubytter.new(ARGV[0], ARGV[1])
p client.update(ARGV[2])
