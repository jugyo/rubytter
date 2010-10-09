# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

class OAuthRubytter
  describe "OAuthRubytter with login" do
    before do
      access_token = Object.new
      @rubytter = OAuthRubytter.new(access_token)
      @rubytter.login = 'test'
    end

    describe 'path include :user' do
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

      it 'should add member to list' do
        @rubytter.should_receive(:post).with("/test/foo/members", {:id=>"jugyo"})
        @rubytter.add_member_to_list('foo', 'jugyo')
      end

      it 'should remove member to list' do
        @rubytter.should_receive(:delete).with("/test/foo/members", {:id=>"jugyo"})
        @rubytter.remove_member_from_list('foo', 'jugyo')
      end
    end
  end
  describe "OAuthRubytter without login" do
    before do
      access_token = Object.new
      @rubytter = OAuthRubytter.new(access_token)
    end

    describe 'path include :user' do
      it 'should POST /:user/list to create list' do
        lambda {
          @rubytter.create_list('foo')
        }.should raise_error(NameUnSetError, "first, you must set @login when create_list use")
      end
    end
  end
end
