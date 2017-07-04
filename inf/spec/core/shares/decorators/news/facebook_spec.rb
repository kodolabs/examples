require 'rails_helper'

describe Shares::Decorators::News::Facebook do
  context 'success' do
    let(:service) { Shares::Decorators::News::Facebook }
    let(:parent) { Shares::Decorators::News::Base }
    let(:link1) { 'http://esquire.com/news_1.html' }
    let(:news1) { create(:news, url: link1) }
    let(:news2) { create(:news, title: 'Title', description: nil) }
    let(:news3) { create(:news, :with_image, title: 'A', description: 'B') }
    let(:image) { news3.image }

    def decorated(data)
      OpenStruct.new(data)
    end

    before(:each) do
      allow(RestClient).to receive(:get).and_return(true)
      allow_any_instance_of(OpenGraph::Base).to receive(:call).and_return(true)
    end

    context 'opengraph' do
      before(:each) do
        allow_any_instance_of(OpenGraph::Base).to receive(:title).and_return(true)
      end

      specify 'success' do
        data = decorated(link: link1)
        res = service.new(news1).call
        expect(res).to eq(data)
      end

      specify 'quote' do
        data = decorated(link: link1, message: 'Awesome text')
        res = service.new(news1, quote: 'Awesome text').call
        expect(res).to eq(data)
      end
    end

    context 'text' do
      before(:each) do
        allow_any_instance_of(OpenGraph::Base).to receive(:title).and_return(false)
      end

      specify 'success' do
        message = "#{news2.title}\n#{news2.url}"
        data = decorated(message: message)
        res = service.new(news2).call
        expect(res).to eq(data)
      end

      specify 'quote' do
        message = "Awesome text\n\n#{news2.title}\n#{news2.url}"
        data = decorated(message: message)
        res = service.new(news2, quote: 'Awesome text').call
        expect(res).to eq(data)
      end
    end

    specify 'with image' do
      allow_any_instance_of(OpenGraph::Base).to receive(:title).and_return(false)
      message = "#{news3.title}\n#{news3.url}\n#{news3.description}"
      data = decorated(image_urls: [image.path], message: message)
      res = service.new(news3).call
      expect(res).to eq(data)
    end
  end
end
