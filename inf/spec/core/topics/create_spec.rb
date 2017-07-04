require 'rails_helper'

describe Topics::Create do
  let(:service) { Topics::Create }

  context 'success' do
    specify 'downcase keyword' do
      form = Topics::TopicForm.from_params(keyword: 'Kodo')
      expect { service.call(form) }.to change(Topic, :count).by(1)
      expect(Topic.last.keyword).to eq('Kodo')
    end
  end

  context 'fail' do
    let(:topic) { create(:topic) }
    specify 'topic already exists' do
      form = Topics::TopicForm.from_params(keyword: topic.keyword.upcase)
      expect { service.call(form) }.to change(Topic, :count).by(0)
      expect(form.valid?).to be_falsey
    end
  end
end
