require 'rails_helper'

describe ImageProcessing::Processors::InitialProcessor do
  let(:convert) { MiniMagick::Tool::Convert.new }

  describe '#process' do
    context 'with empty params' do
      it 'passes nothing to convert' do
        processor = ImageProcessing::Processors::InitialProcessor.new(nil)
        processor.process(convert)
        expect(convert.args).to be_empty
      end
    end

    context 'with all params' do
      let(:processor) do
        ImageProcessing::Processors::InitialProcessor.new(width: 120, height: 15, color: 'black')
      end
      before(:each) { processor.process(convert) }

      it 'passes right commands' do
        expect(convert.args.join(' ')).to eq '-size 120x15 xc:black'
      end
    end
  end
end
