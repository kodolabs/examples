RSpec.configure do |config|
  config.before(:each, stub_facebook: true) do
    pages = [
      {
        'id' => '111',
        'name' => 'Kodo Labs',
        'access_token' => '123456',
        'username' => 'kodolabs'
      },
      {
        'id' => '222',
        'name' => 'Apple Computer',
        'access_token' => '73845768345',
        'username' => 'apple_computer'
      }
    ]
    allow_any_instance_of(Pages::Facebook::Fetch).to receive(:call).and_return(pages)
    allow_any_instance_of(Facebook::FetchStats).to receive(:call).and_return(true)
    allow_any_instance_of(Facebook::SavePosts).to receive(:call).and_return(true)
    allow_any_instance_of(Facebook::FetchPageLikes).to receive(:call).and_return(true)
    allow_any_instance_of(Twitter::REST::Client).to receive(:update).and_return(true)
  end

  config.before(:each, stub_facebook_auth: true) do
    allow_any_instance_of(Koala::Facebook::OAuth).to receive(:get_app_access_token)
  end

  config.before(:each, stub_facebook_campaign: true) do
    allow_any_instance_of(User::BaseController).to(
      receive(:fb_account_options).and_return({})
    )
  end
end
