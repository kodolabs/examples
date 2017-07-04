require 'rails_helper'

describe Webhooks::Facebook::Page::Info do
  let(:service) { Webhooks::Facebook::Page::Info }
  let(:page) { create(:page, :facebook) }

  context 'success' do
    specify 'update' do
      page
      expect(PageWorker).to receive(:perform_async).once.with(page.id)
      service.new(page.uid).call
    end
  end
end
