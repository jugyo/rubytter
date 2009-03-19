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
      @rubytter.remove_status(1)
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
      @rubytter.remove_direct_message(1)
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

    it 'should respond to update_status' do
      @rubytter.should_receive(:post).with('/statuses/update', {:status => 'test'})
      @rubytter.update_status(:status => 'test')
    end

    # friendship

    it 'should respond to follow' do
      @rubytter.should_receive(:post).with('/friendships/create/test', {})
      @rubytter.follow('test')
    end

    it 'should respond to leave' do
      @rubytter.should_receive(:delete).with('/friendships/destroy/test', {})
      @rubytter.leave('test')
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

    it 'should respond to http_request' do
      @rubytter.should_receive(:http_request) {|host, req, param_str| param_str.should == 'status=test'}
      @rubytter.update_status(:status => 'test')
    end

    it 'should respond to search (1)' do
      @rubytter.should_receive(:http_request) do |host, req, param_str|
        req.path.should == '/search.json?q=test'
        host.should == 'search.twitter.com'
      end
      @rubytter.search('test')
    end

    it 'should respond to search with params (1)' do
      @rubytter.should_receive(:http_request) do |host, req, param_str|
        req.path.should =~ /\/search.json\?/
        req.path.should =~ /q=test/
        req.path.should =~ /lang=ja/
      end
      @rubytter.search('test', :lang => 'ja')
    end

    it 'should respond to to_param_str' do
      param_str = @rubytter.to_param_str(:page => 2, :foo => 'bar')
      p param_str
      param_str.should =~ /^.+?=.+?&.+?=.+?$/
      param_str.should =~ /page=2/
      param_str.should =~ /foo=bar/
    end

    it 'should raise when call to_param_str with invalid arg' do
      lambda { @rubytter.to_param_str(nil) }.should raise_error(ArgumentError)
      lambda { @rubytter.to_param_str('foo') }.should raise_error(ArgumentError)
      lambda { @rubytter.to_param_str(:bar) }.should raise_error(ArgumentError)
    end

    it 'should set default header' do
      rubytter = Rubytter.new('test', 'test')
      rubytter.header.should == {'User-Agent', "#{APP_NAME}/#{VERSION} (#{HOMEPAGE})"}
    end

    it 'should able to set custom header 1' do
      rubytter = Rubytter.new('test', 'test',
        {
          :header => {
            'foo' => 'bar'
          }
        }
      )
      rubytter.header['foo'].should == 'bar'
      rubytter.header.has_key?('User-Agent').should == true
    end

    it 'should able to set custom header 2' do
      rubytter = Rubytter.new('test', 'test',
        {
          :header => {
            'User-Agent' => 'foo'
          }
        }
      )
      rubytter.header.should == {'User-Agent' => 'foo'}
    end

    it 'should create struct from json' do
      hash = {
        :a => 'a',
        'b' => 1,
        1 => 'a',
        /regex/ => 'regex',
        nil => nil,
        :c => {:a => 1, :b => 2},
        :d => {:a => {:a => 1, :b => 2}, :b => 1},
        :e => [{:a => 1, :b => 2}, {:c => 3}]
      }
      struct = @rubytter.json_to_struct(hash)
      struct.a.should == 'a'
      struct.b.should == 1
      struct.c.a.should == 1
      struct.c.b.should == 2
      struct.d.a.a.should == 1
      struct.e[0].a.should == 1
      struct.e[0].b.should == 2
      struct.e[1].c.should == 3
      lambda {struct.x}.should raise_error(NoMethodError)
      lambda {struct.regex}.should raise_error(NoMethodError)
    end

  end
end
