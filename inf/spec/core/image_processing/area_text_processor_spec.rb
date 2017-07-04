require 'rails_helper'

describe ImageProcessing::Processors::AreaTextProcessor do
  let(:convert) { MiniMagick::Tool::Convert.new }

  describe '#process' do
    context 'with empty params' do
      it 'passes nothing to convert' do
        processor = ImageProcessing::Processors::AreaTextProcessor.new(nil)
        processor.process(convert)
        expect(convert.args).to be_empty
      end
    end

    context 'with all params' do
      let(:text) { 'abcd' }
      let(:processor) do
        ImageProcessing::Processors::AreaTextProcessor.new(text: text, x: 15, y: 25, width: 100, height: 50,
                                                           font: 'Arial', color: 'red', undercolor: 'orange')
      end

      before(:each) { processor.process(convert) }
      it 'cancels pointsize' do
        expect(convert.args).to include('+pointsize')
      end

      it 'clears background' do
        expect(convert.args).to include('#0000')
      end

      it 'passes composite to convert' do
        expect(convert.args).to include('-composite')
      end

      it 'passes text to convert' do
        expect(convert.args.join(' ')).to include("caption:#{text}")
      end

      it 'passes dimensions to convert' do
        expect(convert.args.join(' ')).to include('-size 100x50')
      end

      it 'sets up font' do
        expect(expect(convert.args.join(' ')).to(include '-font Arial'))
      end

      it 'sets up color' do
        expect(convert.args.join(' ')).to(include '-fill red')
      end

      it 'sets up undercolor' do
        expect(convert.args.join(' ')).to(include '-undercolor orange')
      end

      it 'sets up coordinates' do
        expect(convert.args.join(' ')).to(include '-geometry +15+25')
      end

      it 'passes commands at right sequence' do
        processor.process(convert)
        expect(convert.args.last).to(eq '-composite')
      end
    end

    context 'without optional params' do
      let(:processor) do
        ImageProcessing::Processors::AreaTextProcessor.new(text: 'abcd', x: 15, y: 25, width: 100, height: 50)
      end

      before(:each) { processor.process(convert) }

      it 'not sets up font' do
        expect(expect(convert.args.join(' ')).to_not(include '-font'))
      end

      it 'not sets up color' do
        expect(expect(convert.args.join(' ')).to_not(include '-fill'))
      end

      it 'not sets up undercolor' do
        expect(expect(convert.args.join(' ')).to_not(include '-undercolor'))
      end
    end
  end
end
