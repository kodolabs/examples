require 'rails_helper'

describe NewsDecorator do
  specify 'header_url' do
    news = build(:news, url: 'http://www.nytimes.com/123')
    expect(news.decorate.header_url).to eq 'nytimes.com'
  end
end
