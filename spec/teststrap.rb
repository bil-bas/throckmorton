Config = RbConfig if defined? RbConfig # Hack for deprecation warning.

require 'bundler/setup'
Bundler.require :default, :development

RSpec.configure do |config|
  config.mock_framework = :rr
end

require_relative "../lib/main"

Object.instance_variable_get(:@std_outputter).level = 6