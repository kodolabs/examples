require 'rails_helper'

RSpec.describe HistoriesCleanerWorker do
  let(:user) { create :user }
  let(:customer) { user.customer }
  let(:account) { create(:account, :with_facebook_page, customer: customer) }
  let(:facebook_page) { account.pages.facebook.last }

  context 'success' do
    before(:each) { Sidekiq::Testing.inline! }

    context 'stats' do
      let(:old_history) { create(:history, historyable: facebook_page, date: Time.current - 2.years) }
      let(:history) { create(:history, historyable: facebook_page, date: Time.current - 1.month) }

      specify 'clear old stats' do
        old_history
        history
        expect(History.count).to eq(2)
        HistoriesCleanerWorker.new.perform
        expect(History.count).to eq(1)
        expect(History.first).to eq(history)
      end
    end

    context 'demographics' do
      let(:old_history) { create(:demographic, date: Time.current - 2.weeks) }
      let(:history) { create(:demographic, date: Time.current) }

      specify 'clear old demographics stats' do
        old_history
        history
        expect(Demographic.count).to eq(2)
        HistoriesCleanerWorker.new.perform
        expect(Demographic.count).to eq(1)
        expect(Demographic.first).to eq(history)
      end
    end
  end
end
