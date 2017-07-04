require 'rails_helper'

describe Banner::Render do
  context 'validates' do
    it 'width' do
      expect(Banner::Render.call({ height: 150 }.to_json))
        .to broadcast(:error, 'Width must be not null')
    end

    it 'height' do
      expect(Banner::Render.call({ width: 150 }.to_json))
        .to broadcast(:error, 'Height must be not null')
    end
  end

  context 'finishes with error' do
    let(:service) { Banner::Render.new({ width: 150, height: 300 }.to_json) }
    before(:each) { allow(service).to receive(:render_banner).and_raise(StandardError, 'Error happened') }

    it 'passes error message to result' do
      expect(service.call).to broadcast(:error, message: 'Error happened')
    end
  end
end
