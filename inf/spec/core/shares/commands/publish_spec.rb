require 'rails_helper'

describe Shares::Commands do
  let(:account) { create(:account, :with_facebook_page) }
  let(:customer) { account.customer }
  let(:page) { account.owned_pages.last }
  let(:article) { create(:article, owned_pages: [page], customer: customer) }
  let(:command) { Shares::Commands::Publish }
  let(:share) { article.shares.last }
  let(:publication) { share.publications.last }
  let(:notify_service) { Notifications::Show }
  let(:posts_worker) { RecentPostsWorker }
  let(:publication_service) { UpdatePublication }
  let(:fb_command) { Shares::Commands::PublishFacebook }
  let(:fb_decorator) { Shares::Decorators::Articles::Facebook }

  specify 'success' do
    allow_any_instance_of(fb_command).to receive(:call)
    expect_any_instance_of(fb_command).to receive(:call).once

    allow_any_instance_of(fb_decorator).to receive(:call)
    expect_any_instance_of(fb_decorator).to receive(:call).once
    command.new(share.id).call
  end

  context 'errors' do
    before(:each) do
      allow_any_instance_of(fb_decorator).to receive(:call)
    end

    specify 'known error' do
      allow_any_instance_of(fb_command).to receive(:call)
        .and_raise(Koala::Facebook::ClientError)
      expect_any_instance_of(notify_service).to receive(:call).once
      command.new(share.id).call
      expect(publication.error?).to be_truthy
    end

    specify 'video error' do
      error = Koala::Facebook::ClientError.new(400, { error:
        { error_user_msg: 'Video is not supported.' } }.to_json)
      allow_any_instance_of(fb_command).to receive(:call)
        .and_raise(error)
      expect_any_instance_of(notify_service).to receive(:call).once
      command.new(share.id).call
      expect(publication.error?).to be_truthy
    end

    specify 'success' do
      uid = '123123'
      allow_any_instance_of(fb_command).to receive(:call).and_return(uid)
      expect_any_instance_of(fb_command).to receive(:call).once
      allow_any_instance_of(posts_worker).to receive(:perform)
      allow_any_instance_of(publication_service).to receive(:call)
      command.new(share.id).call
      expect(publication.error?).to be_falsey
      expect(publication.account.active).to eq(true)
    end
  end
end
