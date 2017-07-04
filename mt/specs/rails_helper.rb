require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/active_job'
require 'shoulda/matchers'
require 'tilt/coffee'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
ActiveRecord::Migration.maintain_test_schema!

Devise::Async.enabled = false

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.include RSpec::ActiveJob
  config.include FactoryGirl::Syntax::Methods
  config.include Devise::TestHelpers, type: :controller
  config.include Warden::Test::Helpers
  config.include SelectizeHelpers,    type: :feature
  config.include AuthHelpers,         type: :feature
  config.include SweetAlert,          type: :feature

  config.before :suite do
    Warden.test_mode!
  end

  config.after :each do
    ActiveJob::Base.queue_adapter.enqueued_jobs = []
    ActiveJob::Base.queue_adapter.performed_jobs = []
  end

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
