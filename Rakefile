require 'bundler/setup'
Bundler.require :development

require 'rake/clean'
require 'rake/testtask'
require 'rspec/core/rake_task'

Dir[File.expand_path "../tasks/*.rake", __FILE__] .each do |file|
  load file
end

CLEAN.include("*.log")
CLOBBER.include("doc/**/*")

desc "Run specs"
RSpec::Core::RakeTask.new do
end

task :test => :spec
task :default => :spec



