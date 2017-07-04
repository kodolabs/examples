require 'rails_helper'

describe NewsItems::Blacklist do
  context 'success' do
    let(:news) { create(:news, title: 'abc') }
    let(:news2) { create(:news, title: 'ABC') }
    let(:service) { NewsItems::Blacklist }

    specify 'destroy news' do
      news
      news2

      service.new('abc').call
      expect(News.count).to eq(1)
      expect(News.first).to eq(news2)
      expect(BannedKeyword.count).to eq(1)
      expect(BannedKeyword.first.keyword).to eq('abc')
    end
  end
end
