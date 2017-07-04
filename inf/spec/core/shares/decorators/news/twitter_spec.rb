require 'rails_helper'

describe Shares::Decorators::News::Twitter do
  context 'success' do
    let(:service) { Shares::Decorators::News::Twitter }
    let(:parent) { Shares::Decorators::News::Base }
    let(:link1) { 'http://ya.ru' }
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
        data = decorated(message: link1)
        res = service.new(news1).call
        expect(res).to eq(data)
      end

      specify 'quote' do
        data = decorated(message: "Awesome link\n\n#{link1}")
        res = service.new(news1, quote: 'Awesome link').call
        expect(res).to eq(data)
      end
    end

    context 'text' do
      specify 'success' do
        allow_any_instance_of(OpenGraph::Base).to receive(:title).and_return(false)

        message = "#{news2.title}\n#{news2.url}"
        data = decorated(message: message)
        res = service.new(news2).call
        expect(res).to eq(data)
      end

      specify 'quote' do
        allow_any_instance_of(OpenGraph::Base).to receive(:title).and_return(false)

        data = decorated(message: "Awesome link\n\n#{link1}")
        res = service.new(news1, quote: 'Awesome link').call
        expect(res).to eq(data)
      end

      specify 'cut text' do
        allow_any_instance_of(OpenGraph::Base).to receive(:title).and_return(false)

        quote = FFaker::Lorem.characters(200)
        length = 140 - 25 - 3
        truncated_quote = quote.truncate(length)

        data = decorated(message: "#{truncated_quote}\n\n#{link1}")
        res = service.new(news1, quote: quote).call
        expect(res).to eq(data)
      end
    end
  end
end
