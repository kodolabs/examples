require 'rails_helper'

describe Shares::Decorators::Articles::Facebook do
  context 'success' do
    let(:service) { Shares::Decorators::Articles::Facebook }
    let(:parent) { Shares::Decorators::Articles::Base }
    let(:link1) { 'http://esquire.com/news_1.html' }
    let(:article1) { create(:article, content: link1) }
    let(:article2) { create(:article, content: '123') }
    let(:article3) { create(:article, :with_image) }
    let(:image) { article3.images.last }
    let(:article4) { create(:article, content: "Text #{link1}") }

    def decorated(data)
      OpenStruct.new(data)
    end

    context 'opengraph' do
      before(:each) do
        allow(RestClient).to receive(:get).and_return(true)
        allow_any_instance_of(OpenGraph::Base).to receive(:call).and_return(true)
        allow_any_instance_of(OpenGraph::Base).to receive(:title).and_return(true)
      end

      let(:data) { decorated(link: link1) }

      specify 'success' do
        res = service.new(article1).call
        expect(res).to eq(data)
      end

      specify 'contains url' do
        res = service.new(article4).call
        expect(res).to eq(data)
      end
    end

    specify 'text' do
      data = decorated(image_urls: [], message: article2.content)
      res = service.new(article2).call
      expect(res).to eq(data)
    end

    specify 'with images' do
      data = decorated(image_urls: [image.file.path], message: article3.content)
      res = service.new(article3).call
      expect(res).to eq(data)
    end
  end
end
