require 'simplecov'
SimpleCov.start 'rails' do
  add_group 'Core', 'app/core'
  add_group 'Services', 'app/services'
  add_group 'Decorators', 'app/decorators'
  add_group 'Uploaders', 'app/uploaders'
  add_filter 'app/controllers/static_controller.rb'
end

ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'
require 'tilt/coffee'

Dir[Rails.root.join('spec', '**', 'support', '**', '*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

Capybara.default_max_wait_time = 10

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.include AuthHelpers, type: :feature
  config.include SelectizeHelpers, type: :feature
  config.include ShowMeTheCookies, type: :feature

  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
