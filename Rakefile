require "bundler/gem_tasks"
require 'rake/testtask'

# Setup task for complete test suit
desc "Run application test suite"
Rake::TestTask.new("test") do |test|
  test.pattern = "test/**/*_test.rb"
  test.verbose = true
end
