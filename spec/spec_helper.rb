require 'rubygems'
require 'bundler/setup'

require 'awesome_print'
require 'webmock/rspec'
require 'vcr'
require 'docker'
require 'helpers'


VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  # :none   replays all requests
  # :once   record if no casette available, otherwise replay or error
  # :all    re-record all request
  # config.default_cassette_options = {:record => :all}
end


RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.filter_run_excluding :live
  config.order = 'random'
  config.include Helpers
end



