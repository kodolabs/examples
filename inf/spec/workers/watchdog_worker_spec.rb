require 'rails_helper'

RSpec.describe WatchdogWorker do
  let(:old_page_1) { create(:page, last_crawled_at: 2.days.ago) }
  let(:page_1) { create(:page, last_crawled_at: 30.minutes.ago) }

  let(:old_page_2) { create(:page, last_updated_at: 2.days.ago) }
  let(:page_2) { create(:page, last_updated_at: 30.minutes.ago) }

  let(:page_3) { create(:page, last_updated_at: nil, last_crawled_at: nil) }
  context 'success' do
    specify 'old crawled' do
      old_page_1
      page_1

      expect(PostsWorker).to receive(:perform_async).with(old_page_1.id).once
      WatchdogWorker.new.perform
    end

    specify 'old updated' do
      old_page_2
      page_2

      expect(PageWorker).to receive(:perform_async).with(old_page_2.id).once
      WatchdogWorker.new.perform
    end

    context 'without fb owned pages' do
      let(:account) { create(:account, :with_old_crawled_fb_page) }
      let(:page_4) { account.pages.last }

      specify 'success' do
        old_page_2
        page_4
        account

        allow(PageWorker).to receive(:perform_async)
        allow(PostsWorker).to receive(:perform_async)
        expect(PageWorker).to receive(:perform_async).with(old_page_2.id).once
        WatchdogWorker.new.perform
      end
    end
  end
end
