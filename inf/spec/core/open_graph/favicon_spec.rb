require 'rails_helper'

describe OpenGraph::Favicon do
  context 'success' do
    let(:service) { OpenGraph::Favicon }
    let(:url) { 'http://test.com' }
    let(:favicon_1) { 'http://test.com/some/favicon.ico' }
    let(:favicon_2) { 'http://test.com/some/favicon2.ico' }

    let(:page_1) do
      builder = Nokogiri::HTML::Builder.new do |doc|
        doc.html do
          doc.header do
            doc.link(href: favicon_1, rel: 'icon')
          end
        end
      end
      Nokogiri::HTML.parse builder.to_html
    end

    let(:page_2) do
      builder = Nokogiri::HTML::Builder.new do |doc|
        doc.html do
          doc.header do
            doc.link(href: favicon_1, rel: 'icon', sizes: '32x32')
            doc.link(href: favicon_2, rel: 'icon', sizes: '120x120')
          end
        end
      end
      Nokogiri::HTML.parse builder.to_html
    end

    let(:page_3) do
      builder = Nokogiri::HTML::Builder.new
      Nokogiri::HTML.parse builder.to_html
    end

    let(:page_4) do
      builder = Nokogiri::HTML::Builder.new do |doc|
        doc.html do
          doc.header do
            doc.link(href: favicon_1, rel: 'icon', sizes: '120x120')
            doc.link(href: favicon_2, rel: 'apple-touch-icon', sizes: '200x200')
          end
        end
      end
      Nokogiri::HTML.parse builder.to_html
    end

    let(:page_5) do
      builder = Nokogiri::HTML::Builder.new do |doc|
        doc.html do
          doc.header do
            doc.link(rel: 'icon', sizes: '120x120')
          end
        end
      end
      Nokogiri::HTML.parse builder.to_html
    end

    specify 'shortcut' do
      op = service.new(page_1, url)
      op.call
      expect(op.favicon).to eq(favicon_1)
    end

    context 'high quality' do
      specify 'icon' do
        op = service.new(page_2, url)
        op.call
        expect(op.favicon).to eq(favicon_2)
      end

      specify 'mobile' do
        op = service.new(page_4, url)
        op.call
        expect(op.favicon).to eq(favicon_2)
      end
    end

    specify 'no any data' do
      op = service.new(page_3, url)
      op.call
      expect(op.favicon).to eq(nil)
    end

    specify 'invalid meta tags' do
      op = service.new(page_5, url)
      op.call
      expect(op.favicon).to eq(nil)
    end
  end
end
