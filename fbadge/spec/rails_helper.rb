require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'
require 'fileutils'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.include FactoryGirl::Syntax::Methods
  config.include HelperMethods, type: :feature

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.after(:suite) do
    if Rails.env.test?
      FileUtils.rm_rf(Dir["#{Rails.root}/public/system/test/images"])
    end
  end
end
