require 'rails_helper'

describe Twitter::SaveTweetsHashtag do
  let(:page) { create(:page) }

  before do
    stub_const('Twitter::SaveTweets::BORDER_DATE', 1.month.ago)
    stub_const('Twitter::SaveTweetsHashtag::LIMIT', 15)
  end

  context 'limit' do
    specify 'fetch only n posts' do
      page
      tweet = double('tweet')
      allow(tweet).to receive(:id) { rand(1000) }
      allow(tweet).to receive(:created_at) { Time.current }

      tweets = []
      30.times { tweets.push tweet }

      allow_any_instance_of(Twitter::SaveTweets).to receive(:save_post)

      allow_any_instance_of(Twitter::SaveTweetsHashtag).to receive(:loop).and_yield
      allow_any_instance_of(Twitter::Service).to receive(:fetch_by_hashtag)
        .and_return(tweets)

      expect_any_instance_of(Twitter::SaveTweets).to receive(:save_post).exactly(15).times

      Twitter::SaveTweetsHashtag.new(page).call
    end

    specify 'fetch only new posts' do
      page

      new_tweet = double('tweet')
      allow(new_tweet).to receive(:id) { rand(1000) }
      allow(new_tweet).to receive(:created_at) { Time.current }

      old_tweet = double('tweet')
      allow(old_tweet).to receive(:id) { rand(1000) }
      allow(old_tweet).to receive(:created_at) { Date.current - 2.months }

      tweets = [new_tweet, old_tweet]

      allow_any_instance_of(Twitter::SaveTweets).to receive(:save_post)

      allow_any_instance_of(Twitter::SaveTweetsHashtag).to receive(:loop).and_yield
      allow_any_instance_of(Twitter::Service).to receive(:fetch_by_hashtag)
        .and_return(tweets)

      expect_any_instance_of(Twitter::SaveTweets).to receive(:save_post).with(page, new_tweet, {}).once

      Twitter::SaveTweetsHashtag.new(page).call
    end
  end
end
