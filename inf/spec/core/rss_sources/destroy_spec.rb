require 'rails_helper'

describe RssSources::Destroy do
  let(:service) { RssSources::Destroy }

  it 'should destroy given rss source' do
    rss_source = create(:rss_source)
    expect(rss_source.persisted?).to be_truthy
    service.call(rss_source)
    expect(rss_source.persisted?).to be_falsey
  end
end
