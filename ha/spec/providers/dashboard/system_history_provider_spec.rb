require 'rails_helper'

describe Dashboard::SystemHistoryProvider do
  describe 'Amounts of campaigns services' do
    it 'should return amounts by service types' do
      amounts = { seo: 50.2, ppc: 25.3, social: 42.5 }
      create :system_history, amounts: amounts, health: 123
      history = Dashboard::SystemHistoryProvider.new.call

      expect(history[:seo].to_i).to eq 50
      expect(history[:ppc].to_i).to eq 25
      expect(history[:social].to_i).to eq 42
      expect(history[:total].to_i).to eq 118
      expect(history[:health].to_i).to eq 123
    end

    it 'should nothing return when no histories' do
      history = Dashboard::SystemHistoryProvider.new.call

      expect(history[:seo].to_i).to eq 0
      expect(history[:ppc].to_i).to eq 0
      expect(history[:social].to_i).to eq 0
      expect(history[:total].to_i).to eq 0
      expect(history[:health].to_i).to eq 0
    end

    it 'should return collection of histories of last 6 months' do
      amounts = { seo: 50.2, ppc: 25.3, social: 42.5 }
      create :system_history, amounts: amounts, health: 123, date: 8.months.ago.in_time_zone.end_of_week
      create :system_history, amounts: amounts, health: 123, date: 6.months.ago.in_time_zone.end_of_week
      create :system_history, amounts: amounts, health: 123, date: 4.months.ago.in_time_zone.end_of_week
      create :system_history, amounts: amounts, health: 123, date: 2.months.ago.in_time_zone.end_of_week
      create :system_history, amounts: amounts, health: 123, date: Time.zone.now.end_of_week

      histories_data = Dashboard::SystemHistoryProvider.new.collection
      expect(histories_data.first[:data].count).to eq 4
    end
  end
end
