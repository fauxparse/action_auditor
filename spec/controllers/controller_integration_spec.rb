require File.dirname(__FILE__) + '/../spec_helper'

class Thing
  attr_accessor :attributes
  
  def initialize(attributes = {})
    self.attributes = attributes
  end
  
  def to_s
    "Thing(#{attributes.collect { |k, v| "#{k}:#{v}" }.join(", ")})"
  end
  
  def self.clear!
    @things = []
  end
  
  def self.create(params = {})
    returning new(params) do |thing|
      @things << thing
    end
  end
  
  def self.last
    @things.last
  end
end

class TestController < ActionController::Base
  audit "Someone looked at something"
  def simple
    
  end
  
  def unlogged
    
  end
  
  audit { "Message from #{current_user}" }
  def substituted
    
  end
  
  audit { [ "{{user}} created {{thing}}", { :user => current_user, :thing => @thing } ] }
  def complex
    @thing = Thing.create :colour => :red
  end
  
protected
  def current_user
    "Matt"
  end
end

describe TestController do
  [
    ActionAuditor::Auditor::Simple.new,
    ActionAuditor::Auditor::ActiveRecord.new
  ].each do |auditor|
    describe "with #{auditor.class.name.demodulize} auditing" do
      before :each do
        ActionAuditor.auditors = auditor
        Thing.clear!
        auditor.clear!
      end
      
      it "should allow auditing" do
        controller.class.should respond_to(:audit)
      end
      
      it "should log visits to '/index" do
        lambda {
          get :simple
        }.should change(auditor, :size).by(1)
      end
      
      it "should provide a message on visits to /simple" do
        get :simple
        auditor.last.message.should == "Someone looked at something"
      end
      
      it "should not log visits to /unlogged" do
        lambda {
          get :unlogged
        }.should_not change(auditor, :size)
      end
      
      it "should log visits to /substituted" do
        lambda {
          get :substituted
        }.should change(auditor, :size).by(1)
      end

      it "should keep a correct log of visits to /substituted" do
        get :substituted
        auditor.last.message.should == "Message from Matt"
        auditor.last.parameters.should be_empty
      end

      it "should log visits to /complex" do
        lambda {
          get :complex
        }.should change(auditor, :size).by(1)
      end

      it "should keep a correct log of visits to /complex" do
        get :complex
        log = auditor.last
        log.message.should == "Matt created Thing(colour:red)"
        log.parameters[:user].should == "Matt"
        log.parameters[:thing].should be_a(Thing)
      end
    end
  end
end

