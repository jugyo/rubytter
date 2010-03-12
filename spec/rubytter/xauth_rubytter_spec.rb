# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

class XAuthRubytter
  describe XAuthRubytter do
    it 'should set key and secret' do
      XAuthRubytter.init(:key => 'foo', :secret => 'bar')
      XAuthRubytter.class_eval{ @@key }.should == 'foo'
      XAuthRubytter.class_eval{ @@secret }.should == 'bar'
    end
  end
end
