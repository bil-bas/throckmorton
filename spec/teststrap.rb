Config = RbConfig if defined? RbConfig # Hack for deprecation warning.

require 'bundler/setup'
Bundler.require :default, :development

RSpec.configure do |config|
  config.mock_framework = :rr
end

require_relative "../lib/game"