RSpec.configure do |config|
  config.before(:all) do
    FactoryGirl.reload
  end
  config.include FactoryGirl::Syntax::Methods
end
