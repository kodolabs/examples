require 'rails_helper'

describe Shares::Decorators::News::Linkedin do
  context 'success' do
    let(:service) { Shares::Decorators::News::Linkedin }

    let(:news3) { create(:news, :with_image, title: 'A', description: 'B') }
    let(:image) { news3.image }

    def decorated(data)
      OpenStruct.new(data)
    end

    before(:each) do
      allow(RestClient).to receive(:get).and_return(true)
      allow_any_instance_of(OpenGraph::Base).to receive(:call).and_return(true)
    end

    specify 'with image' do
      allow_any_instance_of(OpenGraph::Base).to receive(:title).and_return(false)
      message = "#{news3.title}\n#{news3.url}\n#{news3.description}"
      data = decorated(image_urls: [news3.decorate.external_image_url], message: message)
      res = service.new(news3).call
      expect(res).to eq(data)
    end
  end
end
