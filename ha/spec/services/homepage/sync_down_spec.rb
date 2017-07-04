require 'rails_helper'

describe Crawlers::SyncDown do
  let!(:client) { create :client }
  let!(:domain) { create :domain, name: 'google.com' }
  let!(:blog) { create :blog }
  let!(:host) do
    create :host, domain: domain, active: true, blog: blog, blog_type: :html, sync_mode: :homepage
  end

  def page
    <<-HTML
      <HTML>
        <HEAD><TITLE>Test article</TITLE></HEAD>
        <BODY>
          Some text <a href="https://www.example.com/">anchor</a>
          <a href="https://www.google.com/">invaild</a>
        </BODY>
      </HTML>
    HTML
  end

  describe 'Sync down posts' do
    context 'success' do
      it 'should be saved' do
        allow_any_instance_of(Mechanize).to receive(:get).and_return(
          Mechanize::Page.new
        )
        allow_any_instance_of(Mechanize::Page).to receive(:uri).and_return(
          URI::HTTP.build(host: 'www.google.com')
        )
        allow_any_instance_of(Mechanize::Page).to receive(:body).and_return(page)

        expect(blog.host.domain).to eq domain
        expect(Article.count).to eq 0
        expect(blog.articles.count).to eq 0

        Blogs::SyncDownRunner.new(blog).call

        expect(Article.count).to eq 1
        expect(blog.reload.articles.count).to eq 1
        expect(Link.count).to eq 1

        link = Link.last
        expect(link.link_url).to eq 'https://www.example.com/'

        article = blog.articles.first
        expect(article.title).to eq 'Test article'
      end
    end
  end
end
