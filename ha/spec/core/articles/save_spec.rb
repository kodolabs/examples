require 'rails_helper'

describe Articles::AutoSave do
  let!(:client) { create :client }
  let!(:domain) { create :domain, index_status: 'indexed' }
  let!(:blog) { create :blog }
  let!(:host) { create :host, blog: blog, domain: domain, active: true }
  let!(:setting) { create :setting, var: 'domains_blacklist', value: 'www.google.com' }

  def post(custom = {})
    OpenStruct.new({
      id: 12,
      title: 'Test title',
      slug: 'test-slug',
      url: "http://#{blog.domain}/test",
      author: 'Testov Test',
      published_at: Time.zone.today,
      categories: [],
      body: <<-HTML
        Some text <a href="https://www.example.com/">anchor</a>
        <a href="https://www.google.com/">invaild</a>
      HTML
    }.merge(custom))
  end

  describe '.call' do
    context 'when given valid post' do
      it 'should be created' do
        expect(blog.synced_at).to be_nil
        expect(blog.not_synced?).to be_falsey
        expect(Article.count).to eq(0)
        expect(ArticleImage.count).to eq(0)
        expect(Link.count).to eq(0)

        context = Articles::AutoSave.call(blog: blog, post: post)
        expect(context).to be_a_success

        expect(Article.count).to eq(1)
        expect(ArticleImage.count).to eq(0)
        expect(Link.count).to eq(1)
        expect(Campaign.count).to eq(0)

        article = Article.last

        expect(blog.reload.synced_at).to_not be_nil
        expect(blog.reload.not_synced?).to be_falsey

        expect(article.title).to eq('Test title')
        expect(article.slug).to eq('test-slug')
        expect(article.url).to eq("http://#{blog.domain}/test")
        expect(article.blog.host.author).to eq('Testov Test')
        expect(article.published_at).to eq(Time.zone.today)

        link = Link.last
        expect(link.anchor_text).to eq('anchor')
        expect(link.link_url).to eq('https://www.example.com/')
        expect(link.campaign_id).to be_nil
      end

      it 'should be find and update exist article' do
        expect(blog.synced_at).to be_nil
        expect(blog.not_synced?).to be_falsey

        host.update(author: 'Example')
        article = create :article, title: 'Test title', blog: blog, external_id: nil
        expect(Article.count).to eq(1)
        expect(article.title).to eq('Test title')
        expect(article.blog.host.author).to eq('Example')

        context = Articles::AutoSave.call(blog: blog, post: post)
        expect(context).to be_a_success

        expect(Article.count).to eq(1)

        expect(blog.reload.synced_at).to_not be_nil
        expect(blog.reload.not_synced?).to be_falsey

        article.reload

        expect(article.title).to eq('Test title')
        expect(article.slug).to eq('test-slug')
        expect(article.url).to eq("http://#{blog.domain}/test")
        expect(article.blog.host.author).to eq('Testov Test')
        expect(article.published_at).to eq(Time.zone.today)
        expect(article.external_id.to_i).to eq 12
      end

      it 'should be create new article ignore article from other blog' do
        expect(blog.synced_at).to be_nil
        expect(blog.not_synced?).to be_falsey

        article = create :article, title: 'Test title', external_id: nil
        expect(Article.count).to eq(1)
        expect(article.title).to eq('Test title')
        expect(article.external_id).to be_nil

        context = Articles::AutoSave.call(blog: blog, post: post)
        expect(context).to be_a_success

        expect(Article.count).to eq(2)

        expect(blog.reload.synced_at).to_not be_nil
        expect(blog.reload.not_synced?).to be_falsey

        article_last = Article.last

        expect(article_last).to_not eq article
        expect(article_last.title).to eq('Test title')
        expect(article_last.external_id.to_i).to eq 12

        expect(article.reload.external_id).to be_nil
      end

      it 'link should be associated with campaign' do
        expect(blog.synced_at).to be_nil
        expect(blog.not_synced?).to be_falsey
        expect(Link.count).to eq(0)

        campaign = create :campaign, client: client, domain: 'example.com'

        context = Articles::AutoSave.call(blog: blog, post: post)
        expect(context).to be_a_success

        expect(Link.count).to eq(1)

        link = Link.last
        expect(link.anchor_text).to eq('anchor')
        expect(link.link_url).to eq('https://www.example.com/')
        expect(link.campaign_id).to eq campaign.id

        expect(campaign.reload.health.to_f).to eq(100)
      end

      it 'if campaign has www' do
        expect(blog.synced_at).to be_nil
        expect(blog.not_synced?).to be_falsey
        expect(Link.count).to eq(0)

        campaign = create :campaign, client: client, domain: 'www.example.com'

        context = Articles::AutoSave.call(blog: blog, post: post)
        expect(context).to be_a_success

        expect(Link.count).to eq(1)

        link = Link.last
        expect(link.anchor_text).to eq('anchor')
        expect(link.link_url).to eq('https://www.example.com/')
        expect(link.campaign_id).to eq campaign.id

        expect(campaign.reload.health.to_f).to eq(100)
      end
    end
  end
end
