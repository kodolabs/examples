require 'rails_helper'

describe News do
  context 'detailed search' do
    def search(q)
      News.detailed_search(q)
    end

    context 'rank' do
      let(:news1) { create(:news, title: 'Google', description: nil) }
      let(:news2) { create(:news, title: nil, description: nil, url: 'http://google.com') }
      let(:news3) { create(:news, title: nil, description: 'Google Company') }
      let(:news4) { create(:news, title: 'Amazon', description: nil) }

      specify 'success' do
        expect(search('google')).to eq [news1, news2, news3]
      end
    end

    context 'morphology' do
      let(:news1) { create(:news, title: 'approach', description: nil) }
      let(:news2) { create(:news, title: nil, description: 'approaches') }

      specify 'success' do
        expect(search('approach')).to eq [news1, news2]
      end
    end

    specify 'empty' do
      news = create(:news)
      expect(search(nil)).to eq [news]
    end

    context 'part of word' do
      let(:news1) { create(:news, title: 'Best Android App', description: nil) }
      let(:news2) { create(:news, title: nil, description: 'android company') }

      specify 'success' do
        news1
        news2
        expect(search('andr')).to eq [news1, news2]
      end
    end
  end
end
