require File.dirname(__FILE__) + '/../spec_helper'

class TestController < ActionController::Base
  audit { "Someone looked at the index page" }
  def index
    
  end
  
  def foo
    
  end
end

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end

describe TestController do
  [
    ActionAuditor::Auditor::Simple.new
  ].each do |auditor|
    ActionAuditor.auditors = auditor
    
    describe "with #{auditor.class.name.demodulize} auditing" do
      before :each do
        auditor.clear!
      end
      
      it "should allow auditing" do
        controller.class.should respond_to(:audit)
      end
      
      it "should log visits to '/index" do
        lambda {
          get :index
        }.should change(auditor, :size).by(1)
      end
    end
  end
end
