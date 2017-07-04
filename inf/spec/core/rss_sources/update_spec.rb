require 'rails_helper'

describe RssSources::Update do
  let(:service) { RssSources::Update }

  it 'should update rss source' do
    rss_source = create :rss_source
    form = RssSources::RssSourceForm.from_params(
      rss_source.attributes.merge(
        title: 'New title',
        url: 'https://www.google.com/'
      )
    )
    service.call(form)
    rss_source.reload
    expect(rss_source.title).to eq 'New title'
    expect(rss_source.url).to eq 'https://www.google.com/'
  end

  it 'should update rss source topics' do
    rss_source = create :rss_source
    rss_source.topics.create(keyword: 'test')

    new_topic = create :topic

    rss_source.reload
    expect(rss_source.topics.count).to eq 1
    expect(rss_source.topics.first.keyword).to eq 'test'

    form = RssSources::RssSourceForm.from_params(
      rss_source.attributes.merge(
        topic_ids: [new_topic.id]
      )
    )
    service.call(form)
    rss_source.reload
    expect(rss_source.topics.count).to eq 1
    expect(rss_source.topics.first.keyword).to eq new_topic.keyword
  end
end
