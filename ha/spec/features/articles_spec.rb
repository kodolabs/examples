require 'rails_helper'

feature 'Articles' do
  let(:network) { create :network }
  let!(:blog) { create :blog }
  let!(:host) { create :host, active: true, blog: blog }
  let!(:domain) { create :domain, network: network, status: :active, hosts: [host] }
  let!(:linked_article) { create :article, blog: blog, title: 'article linked' }
  let!(:campaign) { create :campaign }
  let!(:linked_link) do
    create :link, campaign: campaign, article: linked_article, link_url: 'http://google.com'
  end
  let!(:unlinked_article) { create :article, blog: blog, title: 'article unlinked' }
  let!(:unlinked_link) { create :link, article: unlinked_article }
  let!(:archive_article) { create :article, blog: blog, title: 'archive article' }
  let!(:topic) { create :topic, keyword: 'Science' }

  before { user_sign_in }

  describe 'index' do
    it 'display list of linked articles' do
      visit articles_path
      expect(page).to have_content('Showing 1 article')
      expect(page).to have_content(linked_article.title)
      expect(page).to have_content(campaign.domain)
      expect(page).to have_content(linked_article.links.count)
      expect(page).not_to have_content(unlinked_article.title)
      expect(page).not_to have_content(archive_article.title)
    end
  end

  describe 'unlinked' do
    it 'display list of unlinked articles' do
      visit unlinked_articles_path
      expect(page).to have_content('Showing 1 article')
      expect(page).to have_content(unlinked_article.title)
      expect(page).to have_content(unlinked_article.blog.host.domain.name)
      expect(page).not_to have_content(linked_article.title)
      expect(page).not_to have_content(archive_article.title)
    end
  end

  describe 'archive' do
    it 'display list of archived articles' do
      visit archive_articles_path
      expect(page).to have_content('Showing 1 article')
      expect(page).to have_content(archive_article.title)
      expect(page).not_to have_content(linked_article.title)
      expect(page).not_to have_content(unlinked_article.title)
    end
  end

  describe 'show' do
    it 'display details of article' do
      visit article_path(linked_article)
      expect(page).to have_content(domain.name)
      expect(page).to have_content(campaign.domain)
      expect(page).to have_content(linked_link.article.blog.host.blog_type.humanize)
      expect(page).to have_content(linked_link.anchor_text)
    end
  end
end
