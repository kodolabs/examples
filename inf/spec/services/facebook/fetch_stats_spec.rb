require 'rails_helper'

describe Facebook::FetchStats do
  let(:user) { create :user }
  let(:customer) { user.customer }

  before { Timecop.freeze Time.zone.local(2016, 10, 11, 14, 47, 0) }
  after { Timecop.return }

  context 'success' do
    let(:account) { create(:account, :facebook, :demographics, customer: customer) }
    let(:page) { account.pages.facebook.last }

    let(:account_2) { create(:account, :facebook, :with_random_facebook_pages) }
    let(:page_2) { account_2.pages.first }

    context 'stats', vcr: true do
      specify 'fetch stats' do
        Facebook::FetchStats.new(page).call
        expect(page.histories.count).to be > 0
        expect(page.demographics.count).to eq(Demographic.metric_types.count)
      end
    end

    context 'demographics stats', vcr: true do
      let(:history_date) { Time.new(2016, 10, 10, 14, 47, 0).utc.beginning_of_day }
      let(:history) do
        create(
          :demographic, :engaged,
          page: page, genders: { test: 1 }, date: history_date
        )
      end

      context 'fetch stats' do
        specify 'create new record' do
          Facebook::FetchStats.new(page).call
          expect(page.histories.count).to be > 0
          expect(page.demographics.count).to eq(Demographic.metric_types.count)
          page.demographics.each do |record|
            is_valid = record.attributes.except('cities', 'languages').values.all?(&:present?)
            expect(is_valid).to be_truthy
          end
        end

        specify 'update existing records' do
          history

          Facebook::FetchStats.new(page).call
          expect(page.demographics.count).to eq(Demographic.metric_types.count)
          page.demographics.each do |record|
            is_valid = record.attributes.except('cities', 'languages').values.all?(&:present?)
            expect(is_valid).to be_truthy
          end
          expect(history.reload.genders).not_to eq(test: 1)
          expect(history.cities).to be_truthy
        end
      end
    end

    context 'update last updated_at', update: true do
      let(:owned_page) { page_2.owned_pages.last }

      specify 'success' do
        allow_any_instance_of(Facebook::FetchStats).to receive(:fetch_stats)
        expect_any_instance_of(Page).to receive(:touch_owned_pages)
        Facebook::FetchStats.new(page_2).call
      end
    end
  end
end
