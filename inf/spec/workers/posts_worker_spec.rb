require 'rails_helper'

describe PostsWorker do
  context 'success' do
    let(:page) { create(:page) }
    specify 'run save posts' do
      page
      expect_any_instance_of(SavePosts).to receive(:call)
      expect_any_instance_of(DeleteOutdatedPosts).to receive(:call)
      PostsWorker.new.perform(page.id)
    end
  end
end
