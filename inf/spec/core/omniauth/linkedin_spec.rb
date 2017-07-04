require 'rails_helper'
require 'errors/accounts_limit_reached_exception'
require 'errors/account_is_not_uniq_exception'

describe Omniauth::Linkedin do
  let!(:user) { create :user }
  let!(:customer) { user.customer }
  let!(:provider) { providers :linkedin }
  let(:uid) { SecureRandom.hex }
  let!(:params) do
    {
      'omniauth.auth' => {
        provider: 'linkedin',
        uid: uid,
        credentials: {
          token: 'aa',
          expires_at: nil
        },
        info: {
          name: 'somename'
        }
      }
    }.with_indifferent_access
  end

  let(:service) { Omniauth::Linkedin }

  specify 'check account limit' do
    expect_any_instance_of(Customer).to receive(:reached_account_limit?).and_return(true)
    request = double(:request)
    expect(request).to receive(:env) { params }
    expect { service.new(user, request).call }.to raise_error(AccountsLimitReachedException)
  end

  specify 'check account uniqueness' do
    create(:account, :linkedin, uid: uid, customer: customer)
    expect_any_instance_of(Customer).to receive(:reached_account_limit?).and_return(false)
    request = double(:request)
    expect(request).to receive(:env) { params }
    expect { service.new(user, request).call }.to raise_error(AccountIsNotUniqException)
  end

  specify 'create linkedin account' do
    allow_any_instance_of(PageWorker).to receive(:perform)
    expect_any_instance_of(Customer).to receive(:reached_account_limit?).and_return(false)
    request = double(:request)
    allow(request).to receive(:env) { params }
    expect { service.new(user, request).call }.to change(Account, :count).by(1)
  end

  specify 'connect account' do
    account = create(:account)
    expect_any_instance_of(Customer).to receive(:reached_account_limit?).and_return(false)
    request = double(:request)
    allow(request).to receive(:env) { params }
    allow_any_instance_of(Accounts::Connect).to receive(:query).and_return(account)
    expect_any_instance_of(Accounts::Connect).to receive(:query).once
    service.new(user, request).call
  end
end
