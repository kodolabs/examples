require 'rails_helper'

describe Schedule::BaseValidator do
  let(:klass) { Class.new { include ::Schedule::BaseValidator } }
  let(:service) { klass.new }

  specify 'targets' do
    article = double('Article')
    allow(article).to receive(:targets)

    error_instance = double('error')
    allow(error_instance).to receive(:add)
    expect(error_instance).to receive(:add)
    allow(article).to receive(:errors) { error_instance }

    service.validate_targets_presence(article)
  end

  specify 'future date' do
    article = double('Article')
    allow(article).to receive(:date) { 2.days.ago.to_s }
    allow(article).to receive(:time) { 2.days.ago.to_s }

    error_instance = double('error')
    allow(error_instance).to receive(:add)
    expect(error_instance).to receive(:add)
    allow(article).to receive(:errors) { error_instance }

    service.validate_future_date_time(article)
  end
end
