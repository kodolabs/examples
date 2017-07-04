require 'rails_helper'

describe FacebookPostsWorker do
  let(:page) { create(:page) }

  context 'success' do
    specify 'fetch posts' do
      page
      expect_any_instance_of(Facebook::SavePosts).to receive(:call)
      FacebookPostsWorker.new.perform(page.id)
    end
  end
end
