require 'rails_helper'

describe Shares::Decorators::Articles::Twitter do
  context 'success' do
    let(:service) { Shares::Decorators::Articles::Twitter }
    let(:parent) { Shares::Decorators::Articles::Base }
    let(:link1) { 'http://esquire.com/news_1.html' }
    let(:article1) { create(:article, content: link1) }
    let(:article2) { create(:article, content: '123') }

    def decorated(data)
      OpenStruct.new(data)
    end

    specify 'opengraph' do
      allow(RestClient).to receive(:get).and_return(true)
      allow_any_instance_of(OpenGraph::Base).to receive(:call).and_return(true)
      allow_any_instance_of(OpenGraph::Base).to receive(:title).and_return(true)

      data = decorated(message: link1)
      res = service.new(article1).call
      expect(res).to eq(data)
    end

    specify 'text' do
      data = decorated(image_urls: [], message: article2.content)
      res = service.new(article2).call
      expect(res).to eq(data)
    end
  end
end
