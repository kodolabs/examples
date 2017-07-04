require 'rails_helper'

describe LinkedinPostsWorker do
  let(:service) { Linkedin::SavePosts }
  let(:worker) { LinkedinPostsWorker }

  specify 'success' do
    page_id = rand(1..100)
    allow_any_instance_of(service).to receive(:call)
    expect_any_instance_of(service).to receive(:call).once
    worker.new.perform(page_id)
  end
end
