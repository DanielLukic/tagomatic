require 'rubygems'
require 'rake'

$:.unshift File.join(File.dirname(__FILE__), 'lib')
Dir['lib/tasks/*.rb'].sort.each {|t| load t}

task :test => :check_dependencies
task :spec => :check_dependencies
task :default => [:test, :spec]
