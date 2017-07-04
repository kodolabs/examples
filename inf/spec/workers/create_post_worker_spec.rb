require 'rails_helper'

describe CreatePostWorker do
  let(:page) { create(:page) }
  let(:page_service) { Pages::Create::Base }
  let(:posts_service) { Posts::Create::Base }

  specify 'success' do
    allow_any_instance_of(page_service).to receive(:call).and_return(page)
    expect_any_instance_of(page_service).to receive(:call).once
    allow_any_instance_of(posts_service).to receive(:call)
    expect_any_instance_of(posts_service).to receive(:call).once
    CreatePostWorker.new.perform(123, 'esquire')
  end
end
