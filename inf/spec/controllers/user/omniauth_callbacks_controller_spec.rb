require 'rails_helper'

describe User::OmniauthCallbacksController, type: :controller do
  context 'facebook' do
    context 'success' do
      let(:customer) { create(:customer, :with_active_subscr) }
      let(:user) { create(:user, customer: customer) }
      let(:provider) { providers :facebook }

      before do
        allow_any_instance_of(Facebook::AdsAccountsService).to(
          receive(:update).and_return(true)
        )
        request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in user
        provider
      end

      specify 'create facebook account' do
        name = FFaker::Name.name
        OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new(
          provider: 'facebook',
          uid: '123545',
          credentials: {
            token: '123',
            expires_at: 1_473_061_705
          },
          info: {
            name: name
          }
        )

        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:facebook]
        get :facebook
        account = Account.facebook.last
        valid_cookies = { account_id: account.id }.to_json
        expect(response.cookies['followed_modal']).to eq(valid_cookies)
        expect(user.customer.reload.accounts.count).to eq(1)
        expect(response).to redirect_to(user_accounts_path)
        expect(flash[:notice]).to eq "Facebook account #{name} added"
      end
    end
  end

  context 'twitter' do
    context 'success' do
      let(:customer) { create(:customer, :with_active_subscr) }
      let(:user) { create(:user, customer: customer) }
      let(:provider) { providers :twitter }

      before(:each) do
        request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in user
        provider

        allow_any_instance_of(Customer).to receive(:reached_account_limit?).and_return(false)
      end

      specify 'create twitter account' do
        name = FFaker::Name.name

        OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new(
          provider: 'twitter',
          uid: '123545',
          credentials: {
            token: '123',
            secret: '456'
          },
          info: {
            name: name,
            nickname: 'awesome_user'
          }
        )

        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:twitter]
        allow(PostsWorker).to receive(:perform_async)
        get :twitter

        expect(user.customer.reload.accounts.count).to eq(1)
        expect(response).to redirect_to(user_accounts_path)
        expect(flash[:notice]).to eq "Twitter account #{name} added"
        account = Account.twitter.last
        expect(account.username).to eq 'awesome_user'
        valid_cookies = { account_id: account.id }.to_json
        expect(response.cookies['followed_modal']).to eq(valid_cookies)
      end
    end
  end

  context 'google' do
    context 'success' do
      let(:customer) { create(:customer, :with_active_subscr) }
      let(:user) { create(:user, customer: customer) }
      let(:provider) { providers :google }

      before(:each) do
        request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in user
        provider

        allow_any_instance_of(Customer).to receive(:reached_account_limit?).and_return(false)
      end

      specify 'create google account' do
        name = FFaker::Name.name
        expires_at = 1_490_104_524
        uid = SecureRandom.hex
        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
          uid: uid,
          credentials: {
            token: 'aa',
            expires_at: expires_at
          },
          info: {
            name: name,
            email: 'user@gmail.com',
            image: 'http://google.com/logo.jpg'
          }
        )

        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:google_oauth2]
        get :google_oauth2

        expect(user.customer.reload.accounts.count).to eq(1)
        expect(response).to redirect_to(user_accounts_path(setup_google: 1))
        account = Account.google.last
        expect(account.username).to eq 'user'
        expect(account.logo).to eq 'http://google.com/logo.jpg'
        expect(account.name).to eq name
        expect(account.token).to eq 'aa'
        expect(account.expires_at).to eq Time.zone.at(expires_at)
        expect(account.uid).to eq uid
      end
    end
  end

  context 'linkedin' do
    context 'success' do
      let(:customer) { create(:customer, :with_active_subscr) }
      let(:user) { create(:user, customer: customer) }
      let(:provider) { providers :linkedin }

      before do
        request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in user
        provider
      end

      specify 'create linkedin account' do
        name = FFaker::Name.name
        OmniAuth.config.mock_auth[:linkedin] = OmniAuth::AuthHash.new(
          provider: 'linkedin',
          uid: '123545',
          credentials: {
            token: '123',
            expires_at: 1_473_061_705
          },
          info: {
            name: name
          }
        )

        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:linkedin]
        get :linkedin
        expect(user.customer.reload.linkedin_account).to be_truthy
        expect(response).to redirect_to(user_accounts_path)
        expect(flash[:notice]).to eq "Linkedin account #{name} added"
      end
    end
  end
end
