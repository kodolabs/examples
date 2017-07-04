require 'rails_helper'

describe OpenGraph::Base do
  context 'success' do
    let(:service) { OpenGraph::Base }
    let(:page_1) do
      builder = Nokogiri::HTML::Builder.new do |doc|
        doc.html do
          doc.meta(property: 'og:title', content: 'Esquire')
          doc.meta(property: 'og:image', content: 'image.png')
        end
      end
      builder.to_html
    end

    let(:page_2) do
      builder = Nokogiri::HTML::Builder.new do |doc|
        doc.html { doc.meta(name: 'og:title', content: 'Esquire') }
      end
      builder.to_html
    end

    let(:page_3) do
      builder = Nokogiri::HTML::Builder.new do |doc|
        doc.html { doc.meta(name: 'application-name', content: 'PressReader') }
      end
      builder.to_html
    end

    specify 'parse data from tag with property' do
      op = service.new(page_1, nil)
      op.call
      expect(op.title).to eq 'Esquire'
      expect(op.image).to eq 'image.png'
      expect(op.description).to be_blank
    end

    specify 'parse data from tag with name' do
      op = service.new(page_2, nil)
      op.call
      expect(op.title).to eq 'Esquire'
    end

    specify 'parse title form meta application-name' do
      op = service.new(page_3, nil)
      op.call
      expect(op.site_name).to eq 'PressReader'
    end
  end
end
