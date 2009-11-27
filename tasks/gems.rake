require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "action_auditor"
    gemspec.summary = "Keep an audit trail of actions in your application"
    gemspec.description = "Keep an audit trail of actions in your application"
    gemspec.email = "fauxparse@gmail.com"
    gemspec.homepage = "http://github.com/fauxparse/action_auditor"
    gemspec.authors = ["Matt Powell"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
