#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'rubytter'

if ARGV.size < 2
  puts "Usage: ruby #{File.basename(__FILE__)} user_id password"
  exit
end

client = Rubytter.new(ARGV[0], ARGV[1])

puts 'create list...'
list = client.create_list(ARGV[0], 'test')
puts "  => : #{list.full_name}"

puts 'get lists..'
puts '  =>' + client.lists(ARGV[0]).lists.map{|i| i.slug}.inspect

puts 'add member to list...'
add_user = client.user('termtter')
client.add_member_to_list(ARGV[0], list.slug, add_user.id)
members = client.list_members(ARGV[0], list.slug)
puts '  =>' + members.users.map{|i| i.screen_name}.inspect

puts 'remove member from list...'
client.remove_member_from_list(ARGV[0], list.slug, add_user.id)
members = client.list_members(ARGV[0], list.slug)
puts '  =>' + members.users.map{|i| i.screen_name}.inspect

puts 'delete list...'
client.delete_list(ARGV[0], list.slug)

puts 'get lists..'
puts '  =>' + client.lists(ARGV[0]).lists.map{|i| i.slug}.inspect

puts 'done'
