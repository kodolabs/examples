require 'rails_helper'

describe ArticleImage::Saver do
  let(:saver) { ArticleImage::Saver.new('abcd.img', uuid: 4195, banner_data: 'stub') }

  describe '#call' do
    it 'creates an article image' do
      expect { saver.call }.to change { ArticleImage.count }.by(1)
    end
  end

  context 'when save success' do
    before(:each) do
      allow_any_instance_of(ArticleImage).to receive(:save).and_return(true)
      allow_any_instance_of(ArticleImage).to receive_message_chain(:file, :size).and_return(123)
      allow_any_instance_of(ArticleImage).to receive_message_chain(:file, :url).and_return('stub_url')
      allow_any_instance_of(ArticleImage).to receive(:id).and_return(3)
      allow_any_instance_of(ArticleImage).to receive(:banner?).and_return(true)
      allow_any_instance_of(ArticleImage).to receive(:banner_data).and_return('stub')
      allow_any_instance_of(ArticleImage).to receive_message_chain(:file, :preview, :url)
        .and_return('stub_preview_url')
    end

    describe '#errors?' do
      it 'returns false' do
        expect(saver.call.errors?).to eq(false)
      end
    end

    describe '#result' do
      it 'returns correct result' do
        saver.call
        expected = {
          uuid: 4195,
          size: 123,
          url: 'stub_url',
          id: 3,
          thumbnail_url: 'stub_preview_url',
          banner_data: 'stub'
        }
        expect(saver.result).to eq(expected)
      end
    end
  end

  context 'when save not success' do
    before(:each) do
      allow_any_instance_of(ArticleImage).to receive(:save).and_return(false)
    end
    describe '#errors?' do
      it 'returns true' do
        expect(saver.call.errors?).to eq(true)
      end
    end

    describe '#result' do
      before(:each) do
        allow_any_instance_of(ArticleImage).to receive_message_chain(:errors, :full_messages, :first)
          .and_return('abcd file')
      end
      it 'returns error message' do
        saver.call
        expect(saver.result).to include(:message)
      end
    end
  end
end
