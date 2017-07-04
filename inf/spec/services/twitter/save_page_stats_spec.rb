require 'rails_helper'

describe Twitter::SavePageStats do
  context 'success' do
    let(:account) { create(:account, :with_twitter_page) }
    let(:page) { account.pages.last }
    let(:history) do
      create(:history, :lifetime, historyable_id: page.id, likes: 300, date: Date.current - 1.day)
    end

    before { Timecop.freeze Time.zone.local(2016, 10, 25, 0, 10, 0) }
    after { Timecop.return }

    specify 'first history' do
      page
      user = double('Twitter::User')
      allow(user).to receive(:followers_count).and_return(88)
      allow(user).to receive(:screen_name).and_return(page.handle)

      allow_any_instance_of(Twitter::REST::Client).to receive(:users).and_return([user])
      expect_any_instance_of(Page).to receive(:touch_owned_pages)

      expect { Twitter::SavePageStats.new(['username1']).call }.to change(History, :count).by(2)
      day_history = History.day.last
      lifetime_history = History.lifetime.last

      expect(lifetime_history.date).to eq(Date.current)
      expect(lifetime_history.likes).to eq(88)
      expect(lifetime_history.historyable).to eq(page)

      expect(day_history.date).to eq(Date.current)
      expect(day_history.likes).to eq(0)
      expect(day_history.historyable).to eq(page)
    end

    specify 'any history' do
      page
      history
      user = double('Twitter::User')
      allow(user).to receive(:followers_count).and_return(320)
      allow(user).to receive(:screen_name).and_return(page.handle)

      allow_any_instance_of(Twitter::REST::Client).to receive(:users).and_return([user])
      expect { Twitter::SavePageStats.new(['username1']).call }.to change(History, :count).by(2)
      day_history = History.day.last
      lifetime_history = History.lifetime.last

      expect(lifetime_history.date).to eq(Date.current)
      expect(lifetime_history.likes).to eq(320)
      expect(lifetime_history.historyable).to eq(page)

      expect(day_history.date).to eq(Date.current)
      expect(day_history.likes).to eq(20)
      expect(day_history.historyable).to eq(page)
    end
  end
end
