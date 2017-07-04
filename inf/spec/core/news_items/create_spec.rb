require 'rails_helper'

describe NewsItems::Create do
  let(:service) { NewsItems::Create }

  context 'success' do
    let(:valid_params) do
      {
        news: {
          topic_ids: [],
          title: FFaker::Lorem.word,
          description: FFaker::Lorem.word,
          url: FFaker::Internet.http_url,
          image: nil,
          remote_image_url: nil,
          kind: :research,
          source_title: FFaker::Lorem.word
        }
      }
    end
    specify 'create news' do
      form = NewsItems::NewsForm.from_params(valid_params)
      expect { service.call(form) }.to change(News, :count).by(1)
      p = valid_params[:news]
      news = News.last
      expect(news.title).to eq p[:title]
      expect(news.description).to eq p[:description]
      expect(news.url).to eq p[:url]
      expect(news.kind).to eq('research')
    end
  end
end
