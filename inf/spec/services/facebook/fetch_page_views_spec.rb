require 'rails_helper'

describe Facebook::FetchPageViews do
  let(:user) { create :user }
  let(:customer) { user.customer }
  let(:account) { create(:account, :demographics) }
  let(:page) { account.pages.facebook.last }

  context 'success' do
    specify 'fetch stats' do
      api = double('Koala::Facebook::API')
      api_options = { until: Time.new(2017).to_i, period: 'days_28' }
      allow(api).to receive(:get_connection)
      expect(api).to receive(:get_connection).once
        .with(page.api_handle, 'insights/page_views_total', api_options)
      service = Facebook::FetchPageViews.new(api, page, api_options)
      expect { service.call }.not_to raise_error
    end
  end
end
