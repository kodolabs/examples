require 'rails_helper'

describe Page do
  context 'owned pages' do
    let(:account) { create(:account, :facebook, :with_random_facebook_pages) }
    let(:page) { account.pages.first }
    let(:owned_page) { page.owned_pages.last }

    it 'touch' do
      updated = owned_page.last_updated_at
      page.touch_owned_pages
      expect(owned_page.reload.last_updated_at).not_to eq(updated)
    end
  end
end
