require 'rails_helper'

RSpec.describe Article, type: :model do
  let!(:blog) { create :blog }

  describe 'check synced' do
    it 'should be not synced' do
      article_publish = create :article, publishing_status: :publish, blog: blog
      expect(article_publish.not_synced?).to be_truthy

      article_publish.update(synced_at: Time.zone.now + 1.minute)
      expect(article_publish.not_synced?).to be_falsey

      article_pending = create :article, publishing_status: :pending, blog: blog
      expect(article_pending.not_synced?).to be_truthy
    end

    it 'should be synced' do
      article = create :article, publishing_status: :draft, blog: blog
      expect(article.not_synced?).to be_falsey

      article = create :article, publishing_status: :future, blog: blog
      expect(article.not_synced?).to be_falsey

      article = create :article, publishing_status: :private, blog: blog
      expect(article.not_synced?).to be_falsey

      article_publish = create :article, publishing_status: :publish, blog: blog,
                                         synced_at: Time.zone.now + 1.minute
      expect(article_publish.not_synced?).to be_falsey

      article_pending = create :article, publishing_status: :pending, blog: blog,
                                         synced_at: Time.zone.now + 1.minute
      expect(article_pending.not_synced?).to be_falsey
    end

    it 'check list articles for sync' do
      expect(blog.articles.count).to eq 0
      expect(blog.articles.need_sync.count).to eq 0

      create :article, publishing_status: :draft, blog: blog
      create :article, publishing_status: :future, blog: blog
      create :article, publishing_status: :private, blog: blog

      expect(blog.reload.articles.count).to eq 3
      expect(blog.reload.articles.need_sync.count).to eq 0

      article_publish = create :article, publishing_status: :publish, blog: blog
      article_pending = create :article, publishing_status: :pending, blog: blog

      expect(blog.reload.articles.count).to eq 5
      expect(blog.reload.articles.need_sync.count).to eq 2

      article_publish.update(synced_at: Time.zone.now + 1.minute)
      expect(blog.reload.articles.need_sync.count).to eq 1

      article_pending.update(synced_at: Time.zone.now + 1.minute)
      expect(blog.reload.articles.need_sync.count).to eq 0
    end
  end
end
