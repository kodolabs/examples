require 'rails_helper'

describe NewsItems::Update do
  let(:service) { NewsItems::Update }
  let(:news) { create(:news) }
  let(:news_2) { create(:news, :with_image) }

  context 'success' do
    it 'new title' do
      form = NewsItems::NewsForm.from_params(
        news.attributes.merge(
          url: 'https://www.google.com/',
          title: 'Some news'
        )
      )
      service.call(form)
      news.reload
      expect(news.title).to eq 'Some news'
      expect(news.url).to eq 'https://www.google.com/'
    end
  end

  context 'fail' do
    specify 'without title and url' do
      form = NewsItems::NewsForm.from_params(
        news.attributes.merge(
          title: nil
        )
      )
      service.call(form)
      expect(form.errors.full_messages).to include "Title can't be blank"
    end
  end
end
