require 'rails_helper'

RSpec.describe SavePosts do
  let(:facebook_page) { create(:page, :facebook) }
  let(:twitter_page) { create(:page, :twitter) }
  let(:linkedin_page) { create(:page, :linkedin) }
  let(:service) { SavePosts }

  context 'success' do
    before do
      facebook_page
      twitter_page
    end

    specify 'twitter' do
      expect_any_instance_of(Twitter::SaveTweets).to receive(:call)
      service.new(twitter_page).call
    end

    specify 'facebook' do
      expect_any_instance_of(Facebook::SavePosts).to receive(:call)
      service.new(facebook_page).call
    end

    specify 'linkedin' do
      expect_any_instance_of(Linkedin::SavePosts).to receive(:call)
      service.new(linkedin_page).call
    end
  end
end
