require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  blacklisted_urls = [
    'https://js-agent.newrelic.com',
    'https://bam.nr-data.net',
    'https://fonts.googleapis.com'
  ]
  Capybara::Poltergeist::Driver.new(app,
    js_errors: false,
    url_blacklist: blacklisted_urls,
    phantomjs_options: [
      '--ignore-ssl-errors=yes',
      '--ssl-protocol=any'
    ])
end

Capybara.default_max_wait_time = 3
Capybara.javascript_driver = :poltergeist
