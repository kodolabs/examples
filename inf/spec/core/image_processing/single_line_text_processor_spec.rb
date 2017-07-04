require 'rails_helper'

describe ImageProcessing::Processors::SingleLineTextProcessor do
  let(:convert) { MiniMagick::Tool::Convert.new }

  describe '#process' do
    context 'with empty params' do
      it 'passes nothing to convert' do
        processor = ImageProcessing::Processors::SingleLineTextProcessor.new(nil)
        processor.process(convert)
        expect(convert.args).to be_empty
      end
    end

    context 'with all params' do
      let(:processor) do
        ImageProcessing::Processors::SingleLineTextProcessor.new(text: 'abcd', x: 15, y: 25,
                                                                 font: 'Arial', color: 'red', pointsize: 12)
      end

      before(:each) { processor.process(convert) }
      it 'passes pointsize' do
        expect(convert.args.join(' ')).to(include '-pointsize 12')
      end

      it 'passes color' do
        expect(convert.args.join(' ')).to(include '-fill red')
      end

      it 'passes font' do
        expect(convert.args.join(' ')).to(include '-font Arial')
      end

      it 'draws text' do
        expect(convert.args.join(' ')).to(include '-draw text 15,25 "abcd"')
      end

      it 'passes commands at right sequence' do
        processor.process(convert)
        expect(convert.args.join(' ')).to(end_with '-draw text 15,25 "abcd"')
      end
    end
  end
end
