require 'rails_helper'

describe Analytics::Facebook do
  let(:user) { create :user }
  let(:customer) { user.customer }
  let(:facebook_account) do
    create :account, :facebook, :with_facebook_page, :with_facebook_posts, customer: customer
  end
  let(:facebook_page) { facebook_account.pages.facebook.first }
  let(:current_time) { Time.zone.local(2016, 9, 21, 12, 20, 0) }
  let(:stats_service) { Analytics::Facebook }
  before { Timecop.freeze current_time }
  after { Timecop.return }

  context 'success' do
    context 'recent_posts' do
      specify 'index' do
        params = { page_id: facebook_page.id }
        service = stats_service.new(customer, params)
        service.call
        expect(service.show_blank?).to be_falsey
        expect(service.show_filter?).to be_truthy
        expect(service.recent_posts.count).to be > 0
      end
    end

    context 'stats' do
      specify 'fetch stats for year' do
        create(:history, historyable: facebook_page, date: Time.current - 6.months, engaged_users: 0)
        create(:history, historyable: facebook_page, date: Time.current - 2.months, engaged_users: 10)
        create(:history, historyable: facebook_page, date: Time.current - 3.months, engaged_users: 5)
        create(:history, historyable: facebook_page, date: Time.current - 2.years, engaged_users: 3)

        service = stats_service.new(customer, page_id: facebook_page.id)
        service.call
        expect(service.interactions_data.values.inject(:+)).to eq(10)
      end

      specify 'show at minimum 3 months' do
        create(:history, historyable: facebook_page, date: 2.days.ago, engaged_users: 3)
        valid_data = {
          (Date.current - 2.months).beginning_of_month => 0,
          (Date.current - 1.month).beginning_of_month => 0,
          Date.current.beginning_of_month => 3
        }
        service = stats_service.new(customer, page_id: facebook_page.id)
        service.call
        expect(service.interactions_data).to eq(valid_data)
      end
    end
  end

  context 'fail' do
    context 'stats' do
      specify 'no any stats' do
        service = stats_service.new(customer, page_id: facebook_page.id)
        service.call
        expect(service.interactions_data).to be_falsey
      end
    end
  end
end
