# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/spec_helper'

class Rubytter
  describe Rubytter do
    before do
      @rubytter = Rubytter.new('test', 'test')
    end

    it 'should receive ...' do
      @rubytter.should_receive(:user_timeline).with(1)
      @rubytter.user_timeline(1)
      @rubytter.should_receive(:friend_timeline)
      @rubytter.friend_timeline
      @rubytter.should_receive(:replies).with({:page => 2})
      @rubytter.replies(:page => 2)
      # more...
    end

    it 'should get or post' do
      # TODO: split specs
      @rubytter.should_receive(:get).with('/statuses/replies', {})
      @rubytter.replies

      @rubytter.should_receive(:get).with('/statuses/replies', {:page => 2})
      @rubytter.replies(:page => 2)

      @rubytter.should_receive(:get).with('/statuses/user_timeline/1', {})
      @rubytter.user_timeline(1)

      @rubytter.should_receive(:get).with('/users/show/1', {})
      @rubytter.user(1)

      @rubytter.should_receive(:delete).with('/statuses/destroy/1', {})
      @rubytter.destroy(1)
    end

    # direct_messages

    it 'should respond to direct_messages' do
      @rubytter.should_receive(:get).with('/direct_messages', {})
      @rubytter.direct_messages()
    end

    it 'should respond to sent_direct_messages' do
      @rubytter.should_receive(:get).with('/direct_messages/sent', {})
      @rubytter.sent_direct_messages()
    end

    it 'should respond to send_direct_message' do
      @rubytter.should_receive(:post).with('/direct_messages/new', {})
      @rubytter.send_direct_message()
    end

    it 'should respond to destroy_direct_message' do
      @rubytter.should_receive(:delete).with('/direct_messages/destroy/1', {})
      @rubytter.destroy_direct_message(1)
    end

    it 'should respond to direct_message' do
      @rubytter.should_receive(:post).with('/direct_messages/new', {:user => 'test', :text => 'aaaaaaaaaaaaa'})
      @rubytter.direct_message('test', 'aaaaaaaaaaaaa')
    end

    # statuses

    it 'should respond to update' do
      @rubytter.should_receive(:post).with('/statuses/update', {:status => 'test'})
      @rubytter.update('test')
    end

    it 'should respond to status_update' do
      @rubytter.should_receive(:post).with('/statuses/update', {:status => 'test'})
      @rubytter.status_update(:status => 'test')
    end

    # friendship

    it 'should respond to create_friendship' do
      @rubytter.should_receive(:post).with('/friendships/create/test', {})
      @rubytter.create_friendship('test')
    end

    it 'should respond to destroy_friendship' do
      @rubytter.should_receive(:delete).with('/friendships/destroy/test', {})
      @rubytter.destroy_friendship('test')
    end

    it 'should respond to friendship_exists' do
      @rubytter.should_receive(:get).with('/friendships/exists', {:user_a => 'a', :user_b => 'b'})
      @rubytter.friendship_exists(:user_a => 'a', :user_b => 'b')
    end

    # Social Graph Methods

    it 'should respond to followers_ids' do
      @rubytter.should_receive(:get).with('/friends/ids/test', {})
      @rubytter.friends_ids('test')
    end

    it 'should respond to followers_ids' do
      @rubytter.should_receive(:get).with('/followers/ids/test', {})
      @rubytter.followers_ids('test')
    end

  end
end
