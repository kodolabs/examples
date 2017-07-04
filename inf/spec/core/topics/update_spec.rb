require 'rails_helper'

describe Topics::Update do
  let(:service) { Topics::Update }
  let(:topic) { create(:topic) }
  it 'success' do
    form = Topics::TopicForm.from_params(
      topic.attributes.merge(keyword: 'Kodo')
    )
    service.call(form)
    expect(topic.reload.keyword).to eq 'Kodo'
  end
end
