require 'rails_helper'

describe ImageProcessing::Processors::BackgroundImageProcessor do
  let(:convert) { MiniMagick::Tool::Convert.new }

  describe '#process' do
    context 'with empty params' do
      it 'passes nothing to convert' do
        processor = ImageProcessing::Processors::BackgroundImageProcessor.new(nil)
        processor.process(convert)
        expect(convert.args).to be_empty
      end
    end

    context 'with not empty params' do
      let(:source) { 'abcd' }
      let(:processor) do
        ImageProcessing::Processors::BackgroundImageProcessor.new(source: source, width: 25, height: 14)
      end

      it 'passes correct cropping to convert' do
        processor.process(convert)
        expect(convert.args.join(' ')).to include('-crop 25x14+0+0')
      end

      it 'passes correct resizing to convert' do
        processor.process(convert)
        expect(convert.args.join(' ')).to include('-resize 25x14^')
      end

      it 'passes composite to convert' do
        processor.process(convert)
        expect(convert.args).to include('-composite')
      end

      it 'passes composite to convert' do
        processor.process(convert)
        expect(convert.args).to_not include('-colorize')
      end

      it 'passes commands in right sequence' do
        processor.process(convert)
        expect(convert.args[0]).to eq source
        expect(convert.args[1]).to eq '-resize'
        expect(convert.args[2]).to eq '25x14^'
        expect(convert.args[3]).to eq '-gravity'
        expect(convert.args[4]).to eq 'Center'
        expect(convert.args[5]).to eq '-crop'
        expect(convert.args[6]).to eq '25x14+0+0'
        expect(convert.args.last).to eq '+gravity'
      end
    end

    context 'with passed darken param' do
      let(:processor) do
        ImageProcessing::Processors::BackgroundImageProcessor.new(source: 'abcd', width: 25,
                                                                  height: 14, darken: '10%')
      end

      it 'passes composite to convert' do
        processor.process(convert)
        expect(convert.args.join(' ')).to include('-colorize 10%')
      end
    end
  end
end
