require 'rails_helper'

describe OpenGraph::Twitter do
  context 'success' do
    let(:service) { OpenGraph::Twitter }
    let(:page_1) do
      builder = Nokogiri::HTML::Builder.new do |doc|
        doc.html do
          doc.meta(property: 'og:title', content: 'Og title')
          doc.meta(property: 'twitter:title', content: 'Twitter title')
        end
      end
      builder.to_html
    end

    let(:page_2) do
      builder = Nokogiri::HTML::Builder.new do |doc|
        doc.html do
          doc.meta(property: 'og:title', content: 'Og title')
        end
      end
      builder.to_html
    end

    specify 'parse twitter tag firsst' do
      op = service.new(page_1, nil)
      op.call
      expect(op.title).to eq 'Twitter title'
    end

    specify 'parse opengraph tag second' do
      op = service.new(page_2, nil)
      op.call
      expect(op.title).to eq 'Og title'
    end
  end
end
