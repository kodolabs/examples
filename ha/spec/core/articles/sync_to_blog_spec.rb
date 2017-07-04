require 'rails_helper'
require 'sidekiq/testing'

describe Articles::SyncToBlog do
  let!(:client) { create :client }
  let!(:domain) { create :domain, index_status: 'indexed' }
  let!(:blog) { create :blog }
  let!(:host) { create :host, blog: blog, domain: domain, active: true, blog_type: :wordpress }
  let!(:article) { create :article, blog: blog, external_id: nil }

  before do
    Sidekiq::Worker.clear_all
    Subscribers::Jobs.new(article.blog_id, 'sync_up').reset
  end

  describe '.call' do
    context 'success' do
      it 'pending article created and not synced' do
        article.article_pending!

        expect(WpPublishWorker.jobs.size).to eq 0
        Articles::SyncToBlog.call(article: article)
        expect(WpPublishWorker.jobs.size).to eq 1
        expect(Subscribers::Jobs.new(article.blog_id, 'sync_up').get.present?).to be_truthy
      end

      it 'publish article created and not synced' do
        article.article_publish!

        expect(WpPublishWorker.jobs.size).to eq 0
        Articles::SyncToBlog.call(article: article)
        expect(WpPublishWorker.jobs.size).to eq 1
        expect(Subscribers::Jobs.new(article.blog_id, 'sync_up').get.present?).to be_truthy
      end

      it 'draft article created and not synced' do
        article.article_draft!

        expect(WpPublishWorker.jobs.size).to eq 0
        Articles::SyncToBlog.call(article: article)
        expect(WpPublishWorker.jobs.size).to eq 0
        expect(Subscribers::Jobs.new(article.blog_id, 'sync_up').get.present?).to be_falsey
      end

      it 'future article created and not synced' do
        article.article_future!

        expect(WpPublishWorker.jobs.size).to eq 0
        Articles::SyncToBlog.call(article: article)
        expect(WpPublishWorker.jobs.size).to eq 0
        expect(Subscribers::Jobs.new(article.blog_id, 'sync_up').get.present?).to be_falsey
      end

      it 'private article created and not synced' do
        article.article_private!

        expect(WpPublishWorker.jobs.size).to eq 0
        Articles::SyncToBlog.call(article: article)
        expect(WpPublishWorker.jobs.size).to eq 0
        expect(Subscribers::Jobs.new(article.blog_id, 'sync_up').get.present?).to be_falsey
      end

      it 'host not wordpress should not be synced' do
        host.jekyll!
        article.article_pending!

        expect(WpPublishWorker.jobs.size).to eq 0
        Articles::SyncToBlog.call(article: article)
        expect(WpPublishWorker.jobs.size).to eq 0
        expect(Subscribers::Jobs.new(article.blog_id, 'sync_up').get.present?).to be_falsey

        article.html!

        expect(WpPublishWorker.jobs.size).to eq 0
        Articles::SyncToBlog.call(article: article)
        expect(WpPublishWorker.jobs.size).to eq 0
        expect(Subscribers::Jobs.new(article.blog_id, 'sync_up').get.present?).to be_falsey
      end

      it 'if WP article has external_id always should be synced' do
        host.wordpress!
        article.update(external_id: 123)

        Articles::Enum.publishing_statuses.keys.each do |status|
          Sidekiq::Worker.clear_all

          article.update!(publishing_status: status)

          expect(WpPublishWorker.jobs.size).to eq 0
          Articles::SyncToBlog.call(article: article)
          expect(WpPublishWorker.jobs.size).to eq 1
          expect(Subscribers::Jobs.new(article.blog_id, 'sync_up').get.present?).to be_truthy
        end
      end
    end
  end
end
