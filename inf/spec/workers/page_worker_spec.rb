require 'rails_helper'

RSpec.describe PageWorker do
  let(:user) { create :user }
  let(:customer) { user.customer }
  let(:facebook_account) { create(:account, :with_facebook_page, customer: customer) }
  let(:facebook_page) { facebook_account.pages.facebook.last }

  context 'success' do
    specify 'save page info' do
      facebook_page
      expect_any_instance_of(SavePageInfo).to receive(:call)
      PageWorker.new.perform(facebook_page.id)
    end
  end
end
