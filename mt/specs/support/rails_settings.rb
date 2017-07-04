RSpec.configure do |config|
  config.before(:suite) do
    Setting.sender = 'sender@example.com'
  end
end
