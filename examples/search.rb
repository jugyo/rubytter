#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'rubytter'

client = Rubytter.new
client.search(ARGV[0] || 'rubytter').each do |status|
  puts "#{status.user.screen_name}: #{status.text}"
end
