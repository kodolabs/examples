require 'rails_helper'

describe SourcePages::Create do
  let!(:user) { create :user }
  let!(:customer) { user.customer }
  let!(:feed) { customer.feeds.first }
  let!(:service) { SourcePages::Create }
  let!(:provider) { providers :facebook }

  context 'success', vcr: true do
    context 'if page not present' do
      specify 'create source page and page' do
        params = { 'source_page' => {
          'title' => 'title',
          'provider' => provider.id.to_s,
          'handle_type' => 'handle',
          'handle' => 'kodolabs'
        } }
        form = SourcePages::SourcePageForm.from_params(params, feed_id: feed.id)
        service.call(form, feed)
        expect(Page.count).to eq(1)
        expect(SourcePage.count).to eq(1)
      end
    end

    context 'if page present' do
      before do
        @page = create :page, provider: provider, handle_type: 'handle', handle: 'kodolabs'
      end

      specify 'create featured page and assign page' do
        params = { 'source_page' => {
          'title' => 'title',
          'provider' => provider.id.to_s,
          'handle_type' => @page.handle_type,
          'handle' => @page.handle
        } }
        form = SourcePages::SourcePageForm.from_params(params, feed_id: feed.id)
        service.call(form, feed)
        expect(Page.count).to eq(1)
        expect(SourcePage.count).to eq(1)
      end

      specify 'source page with same handle exists', vcr: false do
        create(:source_page, page: @page, feed: feed)
        params = { 'source_page' => {
          'title' => 'some title',
          'provider' => provider.id.to_s,
          'handle_type' => @page.handle_type,
          'handle' => @page.handle
        } }
        form = SourcePages::SourcePageForm.from_params(params, feed_id: feed.id)
        expect(form.valid?).to be_falsey
        expect(form.errors.full_messages).to include 'Handle has already been taken'
        service.call(form, feed)
        expect(Page.count).to eq(1)
        expect(SourcePage.count).to eq(1)
      end
    end
  end
end
