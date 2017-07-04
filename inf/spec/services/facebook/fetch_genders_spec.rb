require 'rails_helper'

describe Facebook::FetchGenders do
  let(:user)      { create :user }
  let(:customer)  { user.customer }
  let(:account) { create(:account, :facebook, :demographics, customer: customer) }
  let(:page) { account.pages.facebook.last }

  context 'success' do
    it 'fetch click rate stats' do
      api = double('Koala::Facebook::API')
      api_options = { since: Time.new(2015).utc.to_i, until: Time.new(2016).utc, period: 'day' }
      allow(api).to receive(:get_connection)
      expect(api).to receive(:get_connection).once
        .with(page.api_handle, 'insights/page_impressions_by_age_gender_unique', api_options)

      service = Facebook::FetchGenders.new(api, page, api_options)
      expect { service.call }.not_to raise_error
    end
  end
end
