require 'rails_helper'

describe Articles::Fetch do
  context 'success' do
    let(:service) { Articles::Fetch }
    let(:image) do
      File.new(
        Rails.root.join('spec', 'fixtures', 'images', 'customer_logo.jpg')
      )
    end
    specify 'save image' do
      graph_data = { image: 'http://text.com/image.jpg', title: 'a', description: 'b' }
      allow_any_instance_of(NewsItems::Fetch).to receive(:call)
      allow_any_instance_of(NewsItems::Fetch).to receive(:data).and_return(graph_data)
      expect_any_instance_of(NewsItems::Fetch).to receive(:call).once

      stub_request(:get, 'http://text.com/image.jpg')
        .to_return(body: image, status: 200)
      s = service.new(url: 'http://test.com', uuid: 'aa')
      s.call
      expect(s.data).to be_truthy
      expect(s.data.keys).to include :image
    end
  end
end
