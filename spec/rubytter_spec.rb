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
      @rubytter.replies({:page => 2})
      # more...
    end

    it 'should get or post' do
      @rubytter.should_receive(:get).with('/statuses/replies', {})
      @rubytter.replies
      @rubytter.should_receive(:get).with('/statuses/replies', {:page => 2})
      @rubytter.replies({:page => 2})
      @rubytter.should_receive(:get).with('/statuses/user_timeline/1', {})
      @rubytter.user_timeline(1)
    end
  end
end
