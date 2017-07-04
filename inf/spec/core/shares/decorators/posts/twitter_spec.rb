require 'rails_helper'

describe Shares::Decorators::Posts::Twitter do
  context 'success' do
    let(:service) { Shares::Decorators::Posts::Twitter }
    let(:parent) { Shares::Decorators::Posts::Base }
    let(:link1) { 'http://esquire.com/post_1.html' }
    let(:post1) { create(:post, link: link1, content: nil) }
    let(:post2) { create(:post) }
    let(:post3) { create(:post, :with_image, link: link1) }
    let(:image) { post3.images.last }

    def decorated(data)
      OpenStruct.new(data)
    end

    before(:each) do
      allow(RestClient).to receive(:get).and_return(true)
      allow_any_instance_of(OpenGraph::Base).to receive(:call).and_return(true)
    end

    context 'opengraph', :quote do
      before(:each) do
        allow_any_instance_of(OpenGraph::Base).to receive(:title).and_return(true)
      end

      specify 'opengraph' do
        data = decorated(message: link1)
        res = service.new(post1).call
        expect(res).to eq(data)
      end

      specify 'quote' do
        data = decorated(message: "Awesome message\n\n\n#{link1}")
        res = service.new(post1, quote: 'Awesome message').call
        expect(res).to eq(data)
      end
    end

    specify 'text' do
      allow_any_instance_of(OpenGraph::Base).to receive(:title).and_return(false)

      data = decorated(message: post2.content)
      res = service.new(post2).call
      expect(res).to eq(data)
    end

    specify 'image' do
      allow_any_instance_of(OpenGraph::Base).to receive(:title).and_return(false)

      raw_data = { image_remote_urls: [image.url], message: "Awesome message\n\n#{post3.link}" }
      data = decorated(raw_data)
      res = service.new(post3, quote: 'Awesome message').call
      expect(res).to eq(data)
    end
  end
end
