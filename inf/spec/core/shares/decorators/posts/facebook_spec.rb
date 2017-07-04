require 'rails_helper'

describe Shares::Decorators::Posts::Facebook do
  context 'success' do
    let(:service) { Shares::Decorators::Posts::Facebook }
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
        data = decorated(link: link1, message: post1.content)
        res = service.new(post1).call
        expect(res).to eq(data)
      end

      specify 'quote' do
        data = decorated(link: link1, message: "Awesome message\n#{post1.content}")
        res = service.new(post1, quote: 'Awesome message').call
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
  end
end
