require 'rails_helper'

describe Analytics::Twitter do
  let!(:user) { create :user }
  let!(:customer) { user.customer }
  let!(:twitter_account) do
    create :account, :twitter, :with_twitter_page, :with_twitter_posts, customer: customer
  end
  let!(:twitter_page) { twitter_account.pages.twitter.first }
  let!(:twitter_post) { twitter_page.posts.first }
  let(:params) { { page_id: twitter_page.id } }
  let(:current_time) { Time.zone.local(2016, 12, 12, 15, 20, 0) }
  let(:stats_service) { Analytics::Twitter }

  before { Timecop.freeze current_time }
  after { Timecop.return }

  context 'success' do
    context 'recent_posts' do
      specify 'index' do
        service = stats_service.new(customer, params)
        service.call
        expect(service.show_blank?).to be_falsey
        expect(service.recent_posts.count).to be > 0
      end
    end

    context 'stats' do
      specify 'fetch stats for month' do
        create(:history, :post,
          historyable: twitter_post,
          date: Time.current - 1.day,
          likes: 8,
          shares: 9)
        create(:history,
          historyable: twitter_post,
          date: Time.current - 2.days,
          likes: 5,
          shares: 6)
        create(:history,
          historyable: twitter_post,
          date: Time.current - 3.days,
          likes: 4,
          shares: 5)
        create(:history,
          historyable: twitter_post,
          date: Time.current - 4.days,
          likes: 2,
          shares: 3)

        service = stats_service.new(customer, params)
        service.call
        expect(service.favorites_data.values).to eq [0, 2, 4, 5, 8]
        expect(service.retweets_data.values).to eq [0, 3, 5, 6, 9]
      end
    end
  end

  context 'fail' do
    context 'stats' do
      specify 'no any stats' do
        service = stats_service.new(customer, params)
        service.call
        expect(service.chartjs_data).to eq nil
      end
    end
  end
end
