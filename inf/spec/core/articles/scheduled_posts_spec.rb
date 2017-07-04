require 'rails_helper'

describe Articles::ScheduledPosts do
  let(:customer) { create(:customer) }
  let(:account) { create(:account, :with_facebook_page) }
  let(:owned_page) { account.owned_pages.last }
  let(:service) { Articles::ScheduledPosts }
  context 'success' do
    let(:article) { create(:article, owned_pages: [owned_page], customer: customer) }
    specify 'already posted' do
      article
      start_date = article.primary_share.created_at.strftime('%d/%m/%Y %H:%M')
      res = {
        id: article.id,
        title: article.title,
        providers: ['facebook'],
        in_future: false,
        start: start_date,
        has_campaign: false,
        shareable_type: 'Article',
        share_id: article.primary_share.id,
        is_pending: true,
        is_error: false
      }
      expect(service.new(customer).query).to eq [res]
    end

    specify 'pending' do
      article
      res = service.new(customer).query
      expect(res.first[:is_pending]).to be_truthy
    end

    context 'scheduled' do
      let(:article) do
        create(:article, owned_pages: [owned_page], customer: customer, scheduled_at: Time.zone.now + 1.day)
      end
      let(:article2) do
        create(:article, owned_pages: [owned_page], customer: customer, scheduled_at: Time.zone.now - 1.day)
      end
      specify 'future' do
        article
        start_date = article.primary_share.scheduled_at.strftime('%d/%m/%Y %H:%M')
        res = {
          id: article.id,
          title: article.title,
          providers: ['facebook'],
          in_future: true,
          start: start_date,
          has_campaign: false,
          shareable_type: 'Article',
          share_id: article.primary_share.id,
          is_pending: true,
          is_error: false
        }
        expect(service.new(customer).query).to eq [res]
      end
    end
  end
end
