require 'rails_helper'

describe ImageProcessing::BannerBuilder do
  let(:initial_width) { 800 }
  let(:initial_height) { 600 }
  let(:builder) { ImageProcessing::BannerBuilder.new(width: initial_width, height: initial_height) }

  context 'after creation' do
    it 'have width and height' do
      expect(builder.width).to be_equal initial_width
      expect(builder.height).to be_equal initial_height
    end

    it 'have only initial processor' do
      expect(builder.processors.size).to be_equal 1
      expect(builder.processors.first).to be_instance_of ImageProcessing::Processors::InitialProcessor
    end
  end

  describe '#with_background_image' do
    let(:sample_source) { 'abcd' }
    it 'adds input image processor' do
      builder.with_background_image(source: sample_source)
      expect(builder.processors.size).to be_equal 2
      expect(builder.processors.last).to be_instance_of ImageProcessing::Processors::BackgroundImageProcessor
    end

    it 'creates input image processor with geometry defined in builder' do
      builder.with_background_image(source: sample_source, darken: '15%')
      expect(builder.processors.last.width).to be_equal initial_width
      expect(builder.processors.last.height).to be_equal initial_height
    end

    it 'creates input image processor with defined source and darken' do
      builder.with_background_image(source: sample_source, darken: '25%')
      expect(builder.processors.last.source).to eq sample_source
      expect(builder.processors.last.darken).to eq '25%'
    end

    context 'with only source argument' do
      it 'creates input image processor with nil darken' do
        builder.with_background_image(source: sample_source)
        expect(builder.processors.last.darken).to eq nil
      end
    end
  end

  describe '#with_image' do
    before(:each) { builder.with_image(source: 'abcd', width: 10, height: 15, x: 5, y: 7) }
    it 'adds banner processor' do
      expect(builder.processors.size).to be_equal 2
      expect(builder.processors.last).to be_instance_of ImageProcessing::Processors::ImageProcessor
    end

    it 'creates banner processor with defined attributes' do
      expect(builder.processors.last.source).to eq 'abcd'
      expect(builder.processors.last.width).to eq 10
      expect(builder.processors.last.height).to eq 15
      expect(builder.processors.last.x).to eq 5
      expect(builder.processors.last.y).to eq 7
    end
  end

  describe '#with_label' do
    it 'adds label processor' do
      builder.with_label(text: 'sample text', x: 15, y: 25)
      expect(builder.processors.size).to be_equal 2
      expect(builder.processors.last).to be_instance_of ImageProcessing::Processors::SingleLineTextProcessor
    end

    it 'passes to processor defined params' do
      builder.with_label(text: 'sample text', x: 15, y: 25, color: 'white', font: 'Georgia', pointsize: 24)
      expect(builder.processors.last.font).to eq 'Georgia'
      expect(builder.processors.last.color).to eq 'white'
      expect(builder.processors.last.x).to eq 15
      expect(builder.processors.last.y).to eq 25
      expect(builder.processors.last.text).to eq 'sample text'
      expect(builder.processors.last.pointsize).to eq 24
    end

    context 'with default optional params' do
      it 'uses default params values' do
        builder.with_label(text: 'sample text', x: 15, y: 25)
        expect(builder.processors.last.font).to eq 'Arial'
        expect(builder.processors.last.color).to eq 'black'
        expect(builder.processors.last.pointsize).to eq 14
      end
    end
  end

  describe '#with_caption' do
    it 'adds caption processor' do
      builder.with_area_text(text: 'sample text', x: 15, y: 25, width: 100, height: 50)
      expect(builder.processors.size).to be_equal 2
      expect(builder.processors.last).to be_instance_of ImageProcessing::Processors::AreaTextProcessor
    end

    it 'passes to processor defined params' do
      builder.with_area_text(text: 'sample text', x: 15, y: 25, width: 100,
                             height: 50, color: 'white', font: 'Georgia')
      expect(builder.processors.last.font).to eq 'Georgia'
      expect(builder.processors.last.color).to eq 'white'
      expect(builder.processors.last.x).to eq 15
      expect(builder.processors.last.y).to eq 25
      expect(builder.processors.last.width).to eq 100
      expect(builder.processors.last.height).to eq 50
      expect(builder.processors.last.text).to eq 'sample text'
    end

    context 'with default optional params' do
      it 'uses default params values' do
        builder.with_area_text(text: 'sample text', x: 15, y: 25, width: 100, height: 50)
        expect(builder.processors.last.font).to eq 'Arial'
        expect(builder.processors.last.color).to eq 'black'
      end
    end
  end

  describe '#build' do
    let(:processor_1) do
      ImageProcessing::Processors::ImageProcessor.new(source: 'a',
                                                      width: 10, height: 15,
                                                      x: 5, y: 7)
    end

    let(:processor_2) do
      ImageProcessing::Processors::ImageProcessor.new(source: 'b',
                                                      width: 10, height: 15,
                                                      x: 5, y: 7)
    end

    it 'calls process method of each processor' do
      allow_any_instance_of(MiniMagick::Tool).to receive(:call)
      builder.processors << processor_1
      builder.processors << processor_2

      expect(processor_1).to receive(:process)
      expect(processor_2).to receive(:process)

      builder.build('abcd.png')
    end
  end
end
