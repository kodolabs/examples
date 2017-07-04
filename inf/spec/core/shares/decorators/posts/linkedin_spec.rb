require 'rails_helper'

describe Shares::Decorators::Posts::Linkedin do
  context 'success' do
    let(:service) { Shares::Decorators::Posts::Linkedin }
    let(:parent) { Shares::Decorators::Posts::Base }
    let(:link1) { 'http://esquire.com/post_1.html' }
    let(:post1) { create(:post, link: link1) }
    let(:post2) { create(:post) }

    def decorated(data)
      OpenStruct.new(data)
    end

    before(:each) do
      allow(RestClient).to receive(:get).and_return(true)
      allow_any_instance_of(OpenGraph::Base).to receive(:call).and_return(true)
    end

    context 'opengraph' do
      before do
        allow_any_instance_of(OpenGraph::Base).to receive(:title).and_return(true)
      end

      specify 'success' do
        data = decorated(message: "#{post1.content}#{link1}")
        res = service.new(post1).call
        expect(res).to eq(data)
      end

      specify 'quote' do
        quote = 'Awesome message'
        data = decorated(message: "#{quote}\n#{post1.content}#{link1}")
        res = service.new(post1, quote: quote).call
        expect(res).to eq(data)
      end
    end

    context 'text' do
      before(:each) do
        allow_any_instance_of(OpenGraph::Base).to receive(:title).and_return(false)
      end
      specify 'success' do
        data = decorated(message: post2.content)
        res = service.new(post2).call
        expect(res).to eq(data)
      end

      specify 'quote' do
        data = decorated(message: "Awesome message\n#{post2.content}")
        res = service.new(post2, quote: 'Awesome message').call
        expect(res).to eq(data)
      end
    end

    context 'image' do
      before do
        allow_any_instance_of(OpenGraph::Base).to receive(:title).and_return(true)
      end

      let(:post_with_image) { create(:post, :with_image) }
      let(:image) { post_with_image.images.last }

      specify 'success' do
        data = decorated(image_urls: [image.url], message: post_with_image.content)
        res = service.new(post_with_image).call
        expect(res).to eq(data)
      end
    end

    context 'video' do
      before do
        allow_any_instance_of(OpenGraph::Base).to receive(:title).and_return(true)
      end

      let(:post_with_video) { create(:post, :with_video) }
      let(:video) { post_with_video.videos.last }
      let(:post3) { create(:post) }
      let(:video2) { create(:video, thumb_url: nil, post: post3) }

      specify 'with thumnail' do
        data = decorated(image_urls: [video.thumb_url], message: "#{post_with_video.content}#{video.url}")
        res = service.new(post_with_video).call
        expect(res).to eq(data)
      end

      specify 'without thumnails' do
        data = decorated(message: "#{post3.content}#{video2.url}")
        res = service.new(post3).call
        expect(res).to eq(data)
      end
    end
  end
end
