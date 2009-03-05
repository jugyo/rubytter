#!/usr/bin/env ruby

require 'rubygems'
require 'rubytter'

client = Rubytter.new
client.search(ARGV[0] || 'rubytter').results.each do |status|
  puts "#{status.from_user}: #{status.text}"
end
