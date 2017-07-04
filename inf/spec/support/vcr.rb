require 'vcr'
require 'webmock/rspec'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.default_cassette_options = { record: :new_episodes }
  config.allow_http_connections_when_no_cassette = false
  config.configure_rspec_metadata!
  config.hook_into :webmock
  config.ignore_localhost = true
end
