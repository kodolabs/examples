require 'rails_helper'

describe RssItem::PubMed do
  let(:rss_source) { create :rss_source, :pubmed }
  let(:service) { RssItem::PubMed }

  context 'success' do
    def create_item(custom = {})
      OpenStruct.new(
        custom.reverse_merge(
          summary: "<p>Authors:  Zhang W</p><p>Abstract<br/>
            BACKGROUND: Obstructive <a href='http://medical.com'>Awesome</a>",
          title: 'Some title',
          author: 'Some author',
          published: Time.zone.now,
          entry_id: SecureRandom.hex
        )
      )
    end

    specify 'url and text' do
      command = service.new(create_item)
      expect(command.url).to eq 'http://medical.com'
      expect(command.text).to include 'Obstructive'
    end
  end
end
