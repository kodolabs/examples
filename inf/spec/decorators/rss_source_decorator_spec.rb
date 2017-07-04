require 'rails_helper'

describe RssSourceDecorator do
  specify 'google' do
    rss_source1 = build(:rss_source, url: 'http://www.nytimes.com/a')
    rss_source2 = build(:rss_source, url: 'http://www.google.com/b')

    expect(rss_source1.decorate.google?).to be_falsey
    expect(rss_source2.decorate.google?).to be_truthy
  end

  specify 'pubmed' do
    rss_source1 = build(:rss_source, url: 'http://www.nytimes.com/a')
    rss_source2 = build(:rss_source, url: 'http://ncbi.nlm.nih.gov/b')

    expect(rss_source1.decorate.pubmed?).to be_falsey
    expect(rss_source2.decorate.pubmed?).to be_truthy
  end
end
