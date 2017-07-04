require 'rails_helper'

describe FileGeometryValidator do
  let(:service) { FileGeometryValidator }
  let(:image) { create(:article_image) }
  let(:command) { service.new(attributes: { a: 1 }, minimum: -> { [401, 400] }) }
  let(:dimensions) { double('dimensions') }

  context 'success' do
    context 'minimum' do
      specify 'minimum range' do
        allow(dimensions).to receive(:geometry) { OpenStruct.new(width: 401, height: 400) }
        command.validate_each(image, :file, dimensions)
        expect(image.errors.full_messages).to be_blank
      end

      specify 'great' do
        allow(dimensions).to receive(:geometry) { OpenStruct.new(width: 999, height: 999) }
        command.validate_each(image, :file, dimensions)
        expect(image.errors.full_messages).to be_blank
      end
    end
  end

  context 'fail' do
    context 'minimum' do
      specify 'small width' do
        allow(dimensions).to receive(:geometry) { OpenStruct.new(width: 400, height: 400) }
        command.validate_each(image, :file, dimensions)
        expect(image.errors.full_messages).to include 'File is too small (should be at least 401x400 pixels)'
      end

      specify 'small height' do
        allow(dimensions).to receive(:geometry) { OpenStruct.new(width: 400, height: 100) }
        command.validate_each(image, :file, dimensions)
        expect(image.errors.full_messages).to include 'File is too small (should be at least 401x400 pixels)'
      end
    end
  end
end
