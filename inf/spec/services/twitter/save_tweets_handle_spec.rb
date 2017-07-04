require 'rails_helper'

describe Twitter::SaveTweetsHandle do
  let(:page) { create(:page) }

  before do
    stub_const('Twitter::SaveTweets::BORDER_DATE', 1.month.ago)
  end

  context 'create' do
    specify 'create history' do
      page

      tweet_user = double('tweet_user')
      allow(tweet_user).to receive(:name) { 1 }
      allow(tweet_user).to receive(:screen_name) { 2 }

      uri = double('uri')
      allow(uri).to receive(:origin) { 1 }
      allow(uri).to receive(:request_uri) { 2 }

      tweet = double('tweet')
      allow(tweet).to receive(:created_at) { Time.current }
      allow(tweet).to receive(:id) { rand(1000) }
      allow(tweet).to receive(:favorite_count) { 10 }
      allow(tweet).to receive(:retweet_count) { 10 }
      allow(tweet).to receive(:full_text) { 10 }
      allow(tweet).to receive(:user) { tweet_user }
      allow(tweet).to receive(:attrs) { Hash.new }
      allow(tweet).to receive(:uri) { uri }
      allow(tweet).to receive(:media) { nil }
      allow(tweet).to receive(:retweeted_status) { nil }

      allow_any_instance_of(Twitter::SaveTweetsHandle).to receive(:loop).and_yield
      allow_any_instance_of(Twitter::Service).to receive(:fetch_timeline) do
        [tweet]
      end
      Twitter::SaveTweetsHandle.new(page, 'save_history' => true).call
      expect(Post.count).to eq(1)
      expect(History.count).to eq(2)
      expect(History.day.count).to eq(1)
      expect(History.lifetime.count).to eq(1)
      page.histories.each do |h|
        expect(h.shares).to eq(10)
        expect(h.likes).to eq(10)
      end
    end
  end

  context 'update' do
    let(:post) { create(:post, page: page, likes_count: 10, shares_count: 10) }
    let(:post_2) { create(:post, page: page, uid: rand(1000)) }
    let(:day_history) do
      create(:history, :post, :day,
        historyable: post_2,
        date: Date.current - 1.day,
        shares: 3,
        likes: 3)
    end
    let(:lifetime_history) do
      create(:history, :post, :lifetime,
        historyable: post_2,
        date: Date.current - 1.day,
        shares: 8,
        likes: 8)
    end

    before(:each) do
      allow_any_instance_of(Twitter::SaveTweetsHandle).to receive(:loop).and_yield
    end

    specify 'skip post' do
      post

      tweet = double('tweet')
      allow(tweet).to receive(:created_at) { Time.current }
      allow(tweet).to receive(:id) { post.uid }
      allow(tweet).to receive(:favorite_count) { 10 }
      allow(tweet).to receive(:retweet_count) { 10 }

      allow_any_instance_of(Twitter::Service).to receive(:fetch_timeline) do
        [tweet]
      end
      Twitter::SaveTweetsHandle.new(page).call
      updated_post = post.reload

      expect(updated_post.shares_count).to eq(10)
      expect(updated_post.likes_count).to eq(10)
    end

    specify 'update likes and shares' do
      post_2
      day_history
      lifetime_history
      tweet = double('tweet')
      allow(tweet).to receive(:created_at) { Time.current }
      allow(tweet).to receive(:id) { post_2.uid.to_i }
      allow(tweet).to receive(:favorite_count) { 20 }
      allow(tweet).to receive(:retweet_count) { 20 }

      allow_any_instance_of(Twitter::Service).to receive(:fetch_timeline) do
        [tweet]
      end
      Twitter::SaveTweetsHandle.new(page, 'save_history' => true).call
      updated_post = post_2.reload

      expect(updated_post.shares_count).to eq(20)
      expect(updated_post.likes_count).to eq(20)

      updated_day_history = post_2.histories.day.ordered.first
      expect(updated_day_history.likes).to eq(12)
      expect(updated_day_history.shares).to eq(12)

      lifetime_history = post_2.histories.lifetime.ordered.first
      expect(lifetime_history.likes).to eq(20)
      expect(lifetime_history.likes).to eq(20)
    end
  end
end
