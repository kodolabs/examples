require 'rails_helper'

describe FollowedPages::Create do
  context 'success' do
    let(:worker) { SourcePageCreateWorker }
    let(:command) { FollowedPages::Create }
    let(:account) { create(:account, :facebook) }

    specify 'run worker' do
      feed_id = 1
      form = double('form')
      checked_page = {
        handle: 'Awesome handle',
        title: 'Awesome title'
      }.with_indifferent_access
      allow(form).to receive(:checked_pages).and_return([checked_page])
      expect(form).to receive(:checked_pages).once
      allow(form).to receive(:feed_id).and_return(feed_id)
      expect(form).to receive(:feed_id).once
      allow(form).to receive(:account).and_return(account)
      allow(worker).to receive(:perform_async)
      valid_options = checked_page.merge(
        provider: account.provider_id,
        feed_id: feed_id,
        handle_type: 'handle'
      ).symbolize_keys
      expect(worker).to receive(:perform_async).with(valid_options).once
      command.new(form).call
    end
  end
end
