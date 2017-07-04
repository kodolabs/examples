require 'rails_helper'

describe Pages::Existing do
  let(:provider) { providers :facebook }

  context 'if page present' do
    specify 'should return existing page' do
      @page = create :page, provider: provider, handle_type: 'handle', handle: 'test'
      expect(Pages::Existing.new(provider.id, @page.handle_type, @page.handle).query).to eq @page
    end
  end

  context 'if page is not present' do
    specify 'should return nil' do
      expect(Pages::Existing.new(provider.id, 'handle', 'test').query).to eq nil
    end
  end
end
