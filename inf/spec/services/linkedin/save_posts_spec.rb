require 'rails_helper'

describe Linkedin::SavePosts do
  let(:service) { Linkedin::SavePosts }
  context 'success' do
    let(:page) { create(:page, :linkedin, :with_linkedin_account) }
    let(:decorated_data) do
      OpenStruct.new(
        uid: SecureRandom.hex,
        content: SecureRandom.hex,
        picture: FFaker::Internet.http_url,
        posted_at: Time.zone.now,
        likes_count: rand(2..5),
        comments_count: rand(2..5)
      )
    end

    specify 'create posts' do
      api_data = double('api_data')
      allow_any_instance_of(Linkedin::Posts).to receive(:index).and_return(api_data)
      expect_any_instance_of(Linkedin::Posts).to receive(:index)
        .once.with(page.uid)
      allow_any_instance_of(Posts::Decorators::Linkedin).to receive(:call).and_return([decorated_data])
      expect_any_instance_of(Posts::Decorators::Linkedin).to receive(:call).once

      service.new(page).call
      reloaded_page = page.reload
      expect(reloaded_page.last_crawled_at).to be_truthy
      expect(reloaded_page.posts_count).to eq(1)
      post = Post.last
      expect(post.uid).to eq(decorated_data.uid)
      expect(post.content).to eq(decorated_data.content)
      expect(post.posted_at.to_i).to eq(decorated_data.posted_at.to_i)
      expect(post.likes_count).to eq(decorated_data.likes_count)
      expect(post.comments_count).to eq(decorated_data.comments_count)
      expect(post.images.last.url).to eq(decorated_data.picture)
    end
  end
end
