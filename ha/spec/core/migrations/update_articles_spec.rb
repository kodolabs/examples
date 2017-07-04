require 'rails_helper'

describe Migrations::UpdateArticles do
  let!(:domain) { create :domain, name: 'google.com', status: :active }
  let!(:blog) { create :blog }
  let!(:host) { create :host, domain: domain, blog: blog, active: true }
  let!(:articles) do
    create_list :article, 5, blog: blog, external_id: rand(1..100), publishing_status: :publish,
                             synced_at: Time.zone.now + 2.hours
  end

  describe '.call' do
    context 'success' do
      it 'should unpublish blog articles' do
        Migrations::UpdateArticles.call(blog: blog)
        blog.reload
        expect(blog.articles.pluck(:external_id).compact.size).to eq 0
        expect(blog.articles.pluck(:synced_at).compact.size).to eq 0
        expect(blog.articles.pluck(:url).compact.size).to eq 0
        expect(blog.articles.first.publishing_status).to eq 'pending'
      end
    end
  end
end
