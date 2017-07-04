require 'rails_helper'

feature 'Articles' do
  let(:network) { create :network }
  let!(:blog) { create :blog }
  let!(:host) { create :host, active: true, blog: blog }
  let!(:article) { create :article, blog: blog }
  let!(:domain) do
    create(:domain, network: network, name: 'amazon.com', status: :active,
                    expires_at: Time.zone.now + 1.day, hosts: [host])
  end
  let!(:topic) { create :topic, keyword: 'Science' }

  before { user_sign_in }

  describe 'Edit page' do
    it 'can update article with topic' do
      visit edit_domain_article_path(domain, article)
      fill_in 'Title', with: 'New Article Title'
      fill_in 'Slug', with: 'test-article'
      select = page.find('select#topics-selectize')
      select.select topic.keyword
      click_on 'Save'
      expect(page).to have_content 'New Article Title'
      expect(page).to have_flash I18n.t('notifications.article_updated')
    end

    it 'can update article - slug automaticly generated', js: true do
      visit edit_domain_article_path(domain, article)
      fill_in 'Title', with: 'New Article Title'
      page.find('#article_title').trigger('blur')
      select_option('topics-selectize', topic.keyword, 'select')
      click_on 'Save'

      expect(article.reload.slug).to eq 'new-article-title'
      expect(page).to have_content 'New Article Title'
      expect(page).to have_flash I18n.t('notifications.article_updated')
    end

    it 'can update article if slug already exist', js: true do
      article.update(slug: 'test-article')

      visit edit_domain_article_path(domain, article)
      fill_in 'Title', with: 'New Article Title'
      select_option('topics-selectize', topic.keyword, 'select')
      click_on 'Save'
      expect(article.reload.slug).to eq 'test-article'
      expect(page).to have_content 'New Article Title'
      expect(page).to have_flash I18n.t('notifications.article_updated')
    end
  end

  describe 'New page' do
    it 'create new article' do
      visit new_domain_article_path(domain)
      fill_in 'Title', with: 'Test Article'
      fill_in 'Body', with: 'Test body'
      fill_in 'Slug', with: 'test-article'
      fill_in 'Published at', with: Time.zone.now.strftime('%d.%m.%Y %H:%M')
      select = page.find('select#topics-selectize')
      select.select topic.keyword
      click_on 'Save'
      expect(page).to have_content 'Test Article'
      expect(page).to have_flash I18n.t('notifications.article_created')
    end

    it 'create new article - slug automaticly generated', js: true do
      visit new_domain_article_path(domain)
      fill_in 'Title', with: 'Test Article with slug'
      page.find('.fr-view p').set('Test body')
      fill_in 'Published at', with: Time.zone.now.strftime('%d.%m.%Y %H:%M')
      select_option('topics-selectize', topic.keyword, 'select')
      page.find('#article_title').trigger('blur')
      click_on 'Save'

      article = Article.last
      expect(article.slug).to eq 'test-article-with-slug'
      expect(page).to have_content 'Test Article'
      expect(page).to have_flash I18n.t('notifications.article_created')
    end

    it 'invalid form - empty form' do
      visit new_domain_article_path(domain)
      click_on 'Save'
      expect(page).to have_selector('.field_with_errors', count: 3)
      expect(page).to have_content "can't be blank"
    end

    it 'invalid form - empty body' do
      visit new_domain_article_path(domain)
      fill_in 'Title', with: 'Test Article'
      click_on 'Save'
      expect(page).to have_selector('.field_with_errors', count: 2)
      expect(page).to have_content "can't be blank"
    end

    it 'invalid form - empty title' do
      visit new_domain_article_path(domain)
      fill_in 'Body', with: 'Test body'
      click_on 'Save'
      expect(page).to have_selector('.field_with_errors', count: 2)
      expect(page).to have_content "can't be blank"
    end
  end

  describe 'Show modal' do
    it 'can show content', js: true do
      visit domain_articles_path(domain, article)

      page.find('.show-article-link').click
      expect(page.find('#article-modal .modal-header')).to have_content article.title
      expect(page.find('#article-modal .modal-body')).to have_content article.body
    end
  end

  describe 'Index page' do
    it 'show draft article' do
      visit domain_articles_path(domain, article)

      expect(page).to have_content I18n.t('articles.index.new')

      expect(page).to have_content article.title
      expect(page).to have_content article.blog.host.author
      expect(page.find('td.links')).to have_content '0'
      expect(page.find('td.published_at')).to have_content article.published_at.to_s(:short)
      expect(page.find('td.published_at')).to have_content article.publishing_status.humanize
      expect(article.not_synced?).to be_falsey
      expect(blog.not_synced?).to be_falsey

      expect(page).to_not have_selector('.article-edited')
    end

    it 'show not synced article' do
      article.article_pending!

      visit domain_articles_path(domain, article)

      expect(blog.not_synced?).to be_truthy
      expect(article.not_synced?).to be_truthy
      expect(page).to have_selector('.article-edited')

      article.update(synced_at: Time.zone.now + 1.minute)

      visit domain_articles_path(domain, article)

      expect(article.not_synced?).to be_falsey
      expect(blog.not_synced?).to be_falsey
      expect(page).to_not have_selector('.article-edited')
    end

    it 'available sync modes' do
      host.wordpress!

      visit domain_articles_path(domain, article)

      options = page.all('.choose-sync-mode li a')
      expect(options.size).to eq 2
      options.each do |option|
        [:wordpress_api, :crawler].include?(option['data-sync-mode'].to_sym)
      end

      host.update!(sync_mode: :crawler, blog_type: :html)

      visit domain_articles_path(domain, article)

      options = page.all('.choose-sync-mode li a')
      expect(options.size).to eq 2
      options.each do |option|
        [:homepage, :crawler].include?(option['data-sync-mode'].to_sym)
      end

      host.update!(sync_mode: :crawler, blog_type: :jekyll)

      visit domain_articles_path(domain, article)
      expect(page).to_not have_selector('.choose-sync-mode li a')
    end
  end
end
