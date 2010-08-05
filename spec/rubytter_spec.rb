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
        {'results' => []}
      end
      @rubytter.search('test')
    end

    it 'should respond to search with params (1)' do
      @rubytter.should_receive(:http_request) do |host, req, param_str|
        req.path.should =~ /\/search.json\?/
        req.path.should =~ /q=test/
        req.path.should =~ /lang=ja/
        {'results' => []}
      end
      @rubytter.search('test', :lang => 'ja')
    end

    it 'should respond to to_param_str' do
      param_str = @rubytter.to_param_str(:page => 2, :foo => 'bar')
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
      rubytter.header.should == {'User-Agent' => "Rubytter/#{Rubytter::VERSION} (http://github.com/jugyo/rubytter)"}
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

    it 'should create struct from json(Hash)' do
      hash = {
        :a => 'a',
        'b' => 1,
        1 => 'a',
        /regex/ => 'regex',
        nil => nil,
        :c => {:a => 1, :b => 2},
        :d => {:a => {:a => 1, :b => 2}, :b => 1},
        :e => [{:a => 1, :b => 2}, {:c => '&quot;&lt;&gt;&amp;'}]
      }
      struct = @rubytter.structize(hash)
      struct.a.should == 'a'
      struct.b.should == 1
      struct.c.a.should == 1
      struct.c.b.should == 2
      struct.d.a.a.should == 1
      struct.e[0].a.should == 1
      struct.e[0].b.should == 2
      struct.e[1].c.should == '"<>&'
      struct.x.should == nil
      struct.regex.should == nil
    end

    it 'should convert to hash using to_hash' do
      hash = {
        :a => 'a',
        'b' => 1,
        :c => {:a => 1, :b => 2}
      }
      struct = @rubytter.structize(hash)
      new_hash = struct.to_hash
      new_hash.should == {:a=>"a", :b=>1, :c=>{:a=>1, :b=>2}}
    end

    it 'should create struct from json(Array)' do
      data = [
        {"status" => {"text" => "foo", "user" => {"screen_name" => "jugyo_foo"}}},
        {"status" => {"text" => "bar", "user" => {"screen_name" => "jugyo_bar"}}},
      ]
      struct = @rubytter.structize(data)
      struct[0].status.text.should == 'foo'
      struct[0].status.user.screen_name.should == 'jugyo_foo'
      struct[1].status.text.should == 'bar'
      struct[1].status.user.screen_name.should == 'jugyo_bar'
    end

    it 'should convert struct to hash' do
      hash = {
        :a => 'a',
        'b' => 1,
        1 => 'a',
        /regex/ => 'regex',
        nil => nil,
        :c => {:a => 1, :b => 2},
        :d => {:a => {:a => 1, :b => 2}, :b => 1},
        :e => [{:a => 1, :b => 2}, {:c => '&quot;&lt;&gt;&amp;'}]
      }
      struct = @rubytter.structize(hash)
      struct.to_hash.should == {
        :a => "a",
        :b => 1,
        :c => {:b => 2, :a => 1},
        :e => [{:b => 2, :a => 1}, {:c => "\"<>&"}],
        :d => {:b => 1, :a => {:b => 2, :a => 1}}
      }
    end

    it 'should convert struct to hash with escape as HTML' do
      pending
      hash = {
        :e => [{:a => 1, :b => 2}, {:c => '&quot;&lt;&gt;&amp;'}]
      }
      struct = @rubytter.structize(hash)
      struct.to_hash(true).should == {"e"=>[{"a"=>1, "b"=>2}, {"c"=>"&quot;&lt;&gt;&amp;"}]}
    end

    it 'should convert struct to json' do
      pending
      hash = {
        :a => 'a',
        'b' => 1,
        1 => 'a',
        /regex/ => 'regex',
        nil => nil,
        :c => {:a => 1, :b => 2},
        :d => {:a => {:a => 1, :b => 2}, :b => 1},
        :e => [{:a => 1, :b => 2}, {:c => '&quot;&lt;&gt;&amp;'}]
      }
      struct = @rubytter.structize(hash)
      struct.to_json.should == '{"a":"a","b":1,"c":{"a":1,"b":2},"d":{"a":{"a":1,"b":2},"b":1},"e":[{"a":1,"b":2},{"c":"\"<>&"}]}'
    end

    it 'should convert struct to json with escape as HTML' do
      pending
      hash = {
        :e => [{:a => 1, :b => 2}, {:c => '&quot;&lt;&gt;&amp;'}]
      }
      struct = Rubytter.structize(hash)
      struct.to_json(true).should == '{"e":[{"a":1,"b":2},{"c":"&quot;&lt;&gt;&amp;"}]}'
    end

    it 'should create same structs from same datas' do
      @rubytter.structize({:a => 'a'}).should == @rubytter.structize({:a => 'a'})
      @rubytter.structize({:a => 'a', :b => {:c => 'c'}}).should ==
        @rubytter.structize({:a => 'a', :b => {:c => 'c'}})
    end

    it 'should be set app_name' do
      rubytter = Rubytter.new('test', 'teat', :app_name => "Foo")
      rubytter.should_receive(:__update_status).with({:status => 'test', :source => "Foo"})
      rubytter.update('test')
    end

    it 'should convert search results to struct' do
      json_data = {
        'id' => '123',
        'text' => 'foo foo bar bar',
        'created_at' => 'Sat, 21 Mar 2009 09:48:20 +0000',
        'source' => '&lt;a href=&quot;http:\/\/twitter.com\/&quot;&gt;web&lt;\/a&gt;',
        'to_user_id' => '20660692',
        'to_user' => 'jugyo_test',
        'from_user_id' => '3748631',
        'from_user' => 'jugyo',
        'profile_image_url' => 'http://s3.amazonaws.com/twitter_production/profile_images/63467667/megane2_normal.png'
      }
      result = @rubytter.search_result_to_hash(json_data)
      result['id'].should == '123'
      result['text'].should == 'foo foo bar bar'
      result['created_at'].should == 'Sat, 21 Mar 2009 09:48:20 +0000'
      result['source'].should == '&lt;a href=&quot;http:\/\/twitter.com\/&quot;&gt;web&lt;\/a&gt;'
      result['in_reply_to_user_id'].should == '20660692'
      result['in_reply_to_screen_name'].should == 'jugyo_test'
      result['user']['id'].should == '3748631'
      result['user']['screen_name'].should == 'jugyo'
      result['user']['profile_image_url'].should == 'http://s3.amazonaws.com/twitter_production/profile_images/63467667/megane2_normal.png'
    end

    it 'should work search' do
      json_data = JSON.parse open(File.dirname(__FILE__) + '/search.json').read

      @rubytter.stub!(:http_request).and_return(json_data)
      statuses = @rubytter.search('termtter')
      status = statuses[0]

      status.id.should == 1365281728
      status.text.should == "よし、add_hook 呼んでるところが無くなった #termtter"
      status.created_at.should == "Sat, 21 Mar 2009 09:48:20 +0000"
      status.source.should == "<a href=\"http://twitter.com/\">web</a>"
      status.in_reply_to_user_id.should == nil
      status.in_reply_to_screen_name.should == nil
      status.in_reply_to_status_id.should == nil
      status.user.id.should == 74941
      status.user.screen_name.should == "jugyo"
      status.user.profile_image_url.should == "http://s3.amazonaws.com/twitter_production/profile_images/63467667/megane2_normal.png"
    end

    it 'should POST /:user/list to create list' do
      @rubytter.should_receive(:post).with("/test/lists", {:name=>"foo"})
      @rubytter.create_list('foo')
    end

    it 'should PUT /:user/list to update list' do
      @rubytter.should_receive(:put).with("/test/lists/foo", {})
      @rubytter.update_list('foo')
    end

    it 'should DELETE /:user/list to delete list' do
      @rubytter.should_receive(:delete).with("/test/lists/foo", {})
      @rubytter.delete_list('foo')
    end

    it 'should GET lists for specified user' do
      @rubytter.should_receive(:get).with("/jugyo/lists", {})
      @rubytter.lists('jugyo')
    end

    it 'should add member to list' do
      @rubytter.should_receive(:post).with("/test/foo/members", {:id=>"jugyo"})
      @rubytter.add_member_to_list('foo', 'jugyo')
    end

    it 'should remove member to list' do
      @rubytter.should_receive(:delete).with("/test/foo/members", {:id=>"jugyo"})
      @rubytter.remove_member_from_list('foo', 'jugyo')
    end

    # TODO: You should write more specs for Lists API...

    it 'should post using access_token' do
      access_token = Object.new
      rubytter = OAuthRubytter.new(access_token)
      response = simple_mock(:body => '{}', :code => '200')
      access_token.should_receive(:post).with(
        "/statuses/update.json",
        {'status' => 'test'},
        {"User-Agent"=>"Rubytter/#{Rubytter::VERSION} (http://github.com/jugyo/rubytter)"}
      ).and_return(response)
      rubytter.update('test')
    end

    it 'should get using access_token' do
      access_token = Object.new
      rubytter = OAuthRubytter.new(access_token)
      response = simple_mock(:body => '{}', :code => '200')
      access_token.should_receive(:get).with(
        '/statuses/friends_timeline.json',
        {"User-Agent"=>"Rubytter/#{Rubytter::VERSION} (http://github.com/jugyo/rubytter)"}
      ).and_return(response)
      rubytter.friends_timeline
    end

    it 'should get with params using access_token' do
      access_token = Object.new
      rubytter = OAuthRubytter.new(access_token)
      response = simple_mock(:body => '{}', :code => '200')
      access_token.should_receive(:get).with(
        '/statuses/friends_timeline.json?page=2',
        {"User-Agent"=>"Rubytter/#{Rubytter::VERSION} (http://github.com/jugyo/rubytter)"}
      ).and_return(response)
      rubytter.friends_timeline(:page => 2)
    end

    def simple_mock(options)
      o = Object.new
      options.each do |k, v|
        o.should_receive(k).and_return(v)
      end
      o
    end

    describe 'spec for ssl' do
      before do
        @ssl_rubytter = Rubytter.new('foo', 'bar', {:enable_ssl => true})
      end

      it 'connection is enabled ssl' do
        @ssl_rubytter.instance_eval{@connection.enable_ssl}.should == true
      end

      it 'connection_for_search is not ever ssl' do
        connection_for_search = @ssl_rubytter.instance_eval{@connection_for_search}
        connection_for_search.enable_ssl.should == false

        @ssl_rubytter.should_receive(:http_request).
          with('search.twitter.com', anything, nil, connection_for_search).
          and_return({'results' => []})
        @ssl_rubytter.search('rubytter')
      end
    end
  end
end
