# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

class Rubytter::OAuth
  describe Rubytter::OAuth do
    context 'ca_file is specified' do 
      before do
        @oauth = Rubytter::OAuth.new('key', 'secret', 'ca_file')
      end

      it 'should get_access_token_with_xauth' do
        consumer = Object.new
        ::OAuth::Consumer.should_receive(:new).
          with(
            'key',
            'secret',
            :site    => 'https://api.twitter.com',
            :ca_file => 'ca_file'
          ).
          and_return(consumer)
        consumer.should_receive(:get_access_token).
          with(
            nil,
            {},
            :x_auth_mode     => "client_auth",
            :x_auth_username => 'login',
            :x_auth_password => 'password'
          ).
          and_return('token')
        token = @oauth.get_access_token_with_xauth('login', 'password')
        token.should == 'token'
      end
    end

    context 'ca_file is not specified' do 
      before do
        @oauth = Rubytter::OAuth.new('key', 'secret')
      end

      it 'should get_access_token_with_xauth' do
        consumer = Object.new
        http = Object.new
        consumer.should_receive(:http).and_return(http)
        http.should_receive(:"verify_mode=").with(OpenSSL::SSL::VERIFY_NONE)
        ::OAuth::Consumer.should_receive(:new).
          with(
            'key',
            'secret',
            :site    => 'https://api.twitter.com'
          ).
          and_return(consumer)
        consumer.should_receive(:get_access_token).
          with(
            nil,
            {},
            :x_auth_mode     => "client_auth",
            :x_auth_username => 'login',
            :x_auth_password => 'password'
          ).
          and_return('token')
        token = @oauth.get_access_token_with_xauth('login', 'password')
        token.should == 'token'
      end
    end
  end
end
