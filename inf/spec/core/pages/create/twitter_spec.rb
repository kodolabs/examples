require 'rails_helper'

describe Pages::Create::Twitter do
  let(:service) { Pages::Create::Twitter }
  let(:page) { create(:page, :twitter, handle: 'xa') }

  context 'success' do
    specify 'create' do
      allow_any_instance_of(Page::FindOrCreateAndFetch).to receive(:call)
      expect_any_instance_of(Page::FindOrCreateAndFetch).to receive(:call).once
      service.new('awesome').call
    end

    specify 'existing' do
      page
      expect(service.new('xa').call).to eq(page)
    end
  end
end
