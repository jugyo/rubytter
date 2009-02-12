# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/spec_helper'

class Hash
  describe Hash do
    before do
      @hash = {
        :a => 'a',
        'b' => 1,
        1 => 'a',
        /regex/ => 'regex',
        nil => nil,
        :c => {:a => 1, :b => 2},
        :d => {:a => {:a => 1, :b => 2}, :b => 1},
        :e => [{:a => 1, :b => 2}, {:c => 3}]
      }
    end

    it 'should be struct' do
      struct = @hash.to_struct
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
