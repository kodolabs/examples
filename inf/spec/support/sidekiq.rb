require 'sidekiq/testing'

RSpec.configure do |_config|
  Sidekiq::Testing.inline!
end
