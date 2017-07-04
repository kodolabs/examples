require 'rails_helper'

describe Page::Update do
  let(:page) { create(:page) }
  context 'success' do
    specify 'update pages' do
      expect(PageWorker).to receive(:perform_async).with(page.id)
      expect(PostsWorker).to receive(:perform_async).with(page.id)

      Page::Update.new(page).call
    end
  end
end
