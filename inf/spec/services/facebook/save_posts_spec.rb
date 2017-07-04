require 'rails_helper'

describe Facebook::SavePosts do
  let(:user) { create :user }
  let(:customer) { user.customer }
  let(:account) { create(:account, :with_facebook_page, customer: customer) }
  let(:page) { account.pages.first }
  let(:post) { create(:post, page: page, likes_count: 100, comments_count: 100) }

  context 'success', :stub_facebook_auth do
    before { Timecop.freeze Time.zone.local(2016, 10, 12, 12, 20, 0) }
    after { Timecop.return }

    context 'create' do
      def generate_post
        {
          uid: SecureRandom.hex(10),
          title: FFaker::Lorem.word,
          content: FFaker::Lorem.phrase,
          likes_count: 0,
          picture: nil,
          posted_at: Time.current,
          shares_count: nil,
          author: nil,
          story: FFaker::Lorem.phrase,
          link: FFaker::Internet.http_url,
          video: nil,
          comments_count: 0,
          description: FFaker::Lorem.word,
          caption: FFaker::Lorem.word
        }.with_indifferent_access
      end

      it 'fetch only 4 posts' do
        api_posts = []
        5.times { api_posts << generate_post }
        result = double('result')
        allow(result).to receive(:next_page) { false }
        allow_any_instance_of(Facebook::Service).to receive(:fetch_posts) { result }
        allow_any_instance_of(Facebook::SavePosts).to receive(:prepare_post_attributes) { api_posts }
        expect { Facebook::SavePosts.new(page, limit: 4).call }.to change(Post, :count).by(4)
      end
    end

    context 'update' do
      let(:media_post) { create(:post, :with_video, :with_image, page: page) }
      let(:attrs) do
        {
          'id' => media_post.uid,
          'created_time' => '2016-10-09T06:31:42+0000',
          'likes' => { 'data' => [], 'summary' => { 'total_count' => 28 } },
          'from' => { 'name' => 'Some awesome name' },
          'comments' => { 'data' => [], 'summary' => { 'total_count' => 28 } }
        }
      end
      before(:each) { media_post }

      it 'update posts' do
        allow_any_instance_of(Facebook::Service).to receive(:fetch_posts) do
          [attrs.merge('name' => 'New post title')]
        end

        allow_any_instance_of(Facebook::SavePosts).to receive(:next_page)

        Facebook::SavePosts.new(page).call
        updated_post = media_post.reload
        expect(updated_post.title).to eq 'New post title'
        expect(updated_post.likes_count).to eq 28
        expect(updated_post.comments_count).to eq 28
      end

      it 'remove image and video' do
        allow_any_instance_of(Facebook::Service).to receive(:fetch_posts) do
          [attrs.merge('source' => nil, 'full_picture' => nil)]
        end

        allow_any_instance_of(Facebook::SavePosts).to receive(:next_page)

        Facebook::SavePosts.new(page).call
        updated_post = media_post.reload
        expect(updated_post.videos.count).to eq(0)
        expect(updated_post.images.count).to eq(0)
      end

      it 'update image and video' do
        allow_any_instance_of(Facebook::Service).to receive(:fetch_posts) do
          [attrs.merge('source' => 'video_url', 'full_picture' => 'image_url')]
        end

        allow_any_instance_of(Facebook::SavePosts).to receive(:next_page)

        Facebook::SavePosts.new(page).call
        updated_post = media_post.reload

        expect(updated_post.videos.count).to eq(1)
        expect(updated_post.images.count).to eq(1)

        expect(updated_post.videos.last.url).to eq('video_url')
        expect(updated_post.images.last.url).to eq('image_url')
      end
    end
  end
end
