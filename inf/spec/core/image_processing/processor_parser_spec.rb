require 'rails_helper'

describe ImageProcessing::ProcessorParser do
  describe '#parse' do
    context 'with empty data' do
      let(:parser) { ImageProcessing::ProcessorParser.new({}) }

      it 'returns empty array' do
        expect(parser.parse).to be_empty
      end
    end

    context 'with text' do
      let(:parser) do
        ImageProcessing::ProcessorParser.new(operations: [
          {
            type: 'text',
            text: 'text',
            gravity: 'center',
            pointsize: 24,
            x: 12,
            y: 22,
            width: 24,
            height: 15
          }
        ])
      end

      it 'returns array with text processor' do
        text_processor = parser.parse[0]
        expect(text_processor).to be_an_instance_of(ImageProcessing::Processors::AreaTextProcessor)
        expect(text_processor.gravity).to eq('center')
        expect(text_processor.x).to eq(12)
        expect(text_processor._y).to eq(22)
        expect(text_processor.width).to eq(24)
        expect(text_processor.height).to eq(15)
        expect(text_processor.pointsize).to eq(24)
      end
    end

    context 'with image id' do
      let(:parser) do
        ImageProcessing::ProcessorParser.new(operations: [
          {
            type: 'image',
            image_id: 'iJHKn4sdfFpgLw',
            x: 12,
            y: 22,
            width: 24,
            height: 15
          }
        ])
      end

      it 'returns array with image processor' do
        image_processor = parser.parse[0]
        expect(image_processor).to be_an_instance_of(ImageProcessing::Processors::ImageProcessor)
        expect(image_processor.x).to eq(12)
        expect(image_processor._y).to eq(22)
        expect(image_processor.width).to eq(24)
        expect(image_processor.height).to eq(15)
        expect(image_processor.source).to eq('public/system/uploads/images/iJHKn4sdfFpgLw.jpg')
      end
    end

    context 'with image' do
      context 'id' do
        let(:parser) do
          ImageProcessing::ProcessorParser.new(operations: [
            {
              type: 'image',
              image_id: 'iJHKn4sdfFpgLw',
              x: 12,
              y: 22,
              width: 24,
              height: 15
            }
          ])
        end

        it 'returns array with image processor' do
          image_processor = parser.parse[0]
          expect(image_processor).to be_an_instance_of(ImageProcessing::Processors::ImageProcessor)
          expect(image_processor.x).to eq(12)
          expect(image_processor._y).to eq(22)
          expect(image_processor.width).to eq(24)
          expect(image_processor.height).to eq(15)
          expect(image_processor.source).to eq('public/system/uploads/images/iJHKn4sdfFpgLw.jpg')
        end
      end

      context 'path' do
        let(:parser) do
          ImageProcessing::ProcessorParser.new(operations: [
            {
              type: 'image',
              image_path: 'app/assets/1.jpg',
              x: 12,
              y: 22,
              width: 24,
              height: 15
            }
          ])
        end

        it 'returns array with image processor' do
          image_processor = parser.parse[0]
          expect(image_processor).to be_an_instance_of(ImageProcessing::Processors::ImageProcessor)
          expect(image_processor.x).to eq(12)
          expect(image_processor._y).to eq(22)
          expect(image_processor.width).to eq(24)
          expect(image_processor.height).to eq(15)
          expect(image_processor.source).to eq('app/assets/1.jpg')
        end
      end
    end

    context 'with background image' do
      context 'id' do
        let(:parser) do
          ImageProcessing::ProcessorParser.new(operations: [
            {
              type: 'background_image',
              image_id: 'iJHKn4sdfFpgLw',
              transparency: '20'
            }
          ])
        end

        it 'returns array with background image processor' do
          background_image_processor = parser.parse[0]
          expect(background_image_processor).to be_an_instance_of(
            ImageProcessing::Processors::BackgroundImageProcessor
          )
          expect(background_image_processor.source).to eq('public/system/uploads/images/iJHKn4sdfFpgLw.jpg')
          expect(background_image_processor.transparency).to eq('20')
        end
      end

      context 'path' do
        let(:parser) do
          ImageProcessing::ProcessorParser.new(operations: [
            {
              type: 'background_image',
              image_path: 'app/assets/2.jpg',
              transparency: '20'
            }
          ])
        end

        it 'returns array with background image processor' do
          background_image_processor = parser.parse[0]
          expect(background_image_processor).to be_an_instance_of(
            ImageProcessing::Processors::BackgroundImageProcessor
          )
          expect(background_image_processor.source).to eq('app/assets/2.jpg')
          expect(background_image_processor.transparency).to eq('20')
        end
      end
    end

    context 'with multiple params' do
      let(:parser) do
        ImageProcessing::ProcessorParser.new(operations: [
          {
            type: 'background_image',
            image_id: 'iJHKn4sdfFpgLw',
            transparency: '20'
          },
          {
            type: 'image',
            image_id: 'iJHKn4sdfFpgLw',
            x: 12,
            y: 22,
            width: 24,
            height: 15
          },
          {
            type: 'text',
            text: 'text',
            alignment: 'center',
            pointsize: 24,
            x: 12,
            y: 22,
            width: 24,
            height: 15
          }
        ])
      end

      it 'returns array with length same as number of operations' do
        expect(parser.parse.length).to eq(3)
      end

      it 'returns array with processors that matches passed operations' do
        result = parser.parse
        expect(result[0]).to be_an_instance_of(ImageProcessing::Processors::BackgroundImageProcessor)
        expect(result[1]).to be_an_instance_of(ImageProcessing::Processors::ImageProcessor)
        expect(result[2]).to be_an_instance_of(ImageProcessing::Processors::AreaTextProcessor)
      end
    end
  end
end
