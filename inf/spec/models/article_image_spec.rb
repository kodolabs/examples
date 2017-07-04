require 'rails_helper'

describe ArticleImage do
  describe '#banner?' do
    context 'when banner_data is empty' do
      let(:image) { ArticleImage.create }

      it 'returns false' do
        expect(image.banner?).to eq(false)
      end
    end

    context 'when banner_data is present' do
      let(:image) { ArticleImage.create(banner_data: '{ stub: 15 }') }

      it 'returns true' do
        expect(image.banner?).to eq(true)
      end
    end
  end
end
