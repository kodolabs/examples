require 'rails_helper'

describe Topics::Destroy do
  let(:service) { Topics::Destroy }
  let(:topic) { create(:topic) }
  it 'success' do
    topic
    service.call(topic)
    expect(topic.persisted?).to be_falsey
  end
end
