require 'rails_helper'

describe Crawlers::SyncDown do
  let!(:client) { create :client }
  let!(:domain) { create :domain, name: 'google.com' }
  let!(:blog) { create :blog }
  let!(:host) do
    create :host, domain: domain, active: true, blog: blog, blog_type: :html, sync_mode: :crawler
  end
  let!(:setting) { create :setting, var: 'domains_blacklist', value: 'www.google.com' }

  def post(custom = {})
    OpenStruct.new({
      id: rand(1..1200),
      url: 'google.com',
      title: 'Test article',
      published_at: Time.zone.now,
      author: 'test',
      categories: [],
      slug: 'test-slug',
      body: <<-HTML
        Some text <a href="https://www.example.com/">anchor</a>
        <a href="https://www.google.com/">invaild</a>
      HTML
    }.merge(custom))
  end

  describe 'Sync down posts' do
    context 'success' do
      it 'empty posts' do
        allow_any_instance_of(Crawlers::Search).to receive(:call).and_return([])

        expect(blog.host.domain).to eq domain
        expect(Article.count).to eq 0
        expect(blog.articles.count).to eq 0

        Blogs::SyncDownRunner.new(blog).call

        expect(Article.count).to eq 0
        expect(blog.reload.articles.count).to eq 0
      end

      it 'search one valid post' do
        allow_any_instance_of(Crawlers::Search).to receive(:call).and_return([post])

        expect(blog.host.domain).to eq domain
        expect(Article.count).to eq 0
        expect(blog.articles.count).to eq 0

        Blogs::SyncDownRunner.new(blog).call

        expect(Article.count).to eq 1
        expect(Link.count).to eq 1
        expect(blog.reload.articles.count).to eq 1

        link = Link.last
        expect(link.link_url).to eq 'https://www.example.com/'
      end

      it 'remove invalid images from content' do
        allow_any_instance_of(Crawlers::Search).to receive(:call).and_return([
          post(body: "<img src='test.jpg'></img> Some text", id: 1),
          post(id: 2)
        ])

        Blogs::SyncDownRunner.new(blog).call

        expect(Article.count).to eq 2
        expect(blog.reload.articles.count).to eq 2

        article = blog.articles.where(external_id: 1).first
        expect(article.body.index("<img src='test.jpg'></img>").blank?).to be_truthy
      end

      it 'stop sync if any post has error' do
        allow_any_instance_of(Crawlers::Search).to receive(:call).and_return([
          post(id: 1, body: nil),
          post(id: 2)
        ])

        Blogs::SyncDownRunner.new(blog).call

        expect(Article.count).to eq 0
        expect(blog.reload.articles.count).to eq 0
        expect(blog.host.last_error.index("Body can't be blank").present?).to be_truthy
      end
    end
  end
end
