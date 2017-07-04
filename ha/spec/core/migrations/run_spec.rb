require 'rails_helper'

describe Migrations::Run do
  let!(:user) { create :user }
  let!(:domain) { create :domain, name: 'google.com', status: :active }

  let!(:blog) { create :blog }
  let!(:host) { create :host, domain: domain, blog: blog, active: true }
  let!(:articles) do
    create_list :article, 5, blog: blog, external_id: rand(1..100), publishing_status: :publish,
                             synced_at: Time.zone.now + 2.hours
  end
  let!(:task) { create :task, :deindexed, status: :pending, taskable: domain, title: 'Deindexed Task' }

  describe '.call' do
    context 'success' do
      it 'should be migrated to new domain' do
        new_domain = create :domain, name: 'facebook.com', status: :pending
        params = {
          migrate_to_new_domain: true,
          blog_type: :wordpress,
          domain_id: new_domain.id,
          reason: 'Uptime',
          status: :inactive
        }

        expect(domain.status).to eq 'active'
        expect(new_domain.status).to eq 'pending'
        expect(domain.blog.present?).to be_truthy
        expect(new_domain.blog.present?).to be_falsey
        expect(Host.count).to eq 1
        expect(blog.articles.pluck(:external_id).compact.size).to eq 5
        expect(blog.articles.pluck(:url).compact.size).to eq 5
        expect(blog.articles.pluck(:synced_at).compact.size).to eq 5
        expect(blog.articles.first.publishing_status).to eq 'publish'
        expect(task.status).to eq 'pending'

        service = Migrations::Run.call(domain: domain, params: params, user: user)
        expect(service.success?).to be_truthy

        domain.reload
        new_domain.reload
        blog.reload
        task.reload
        old_host = domain.hosts.first

        expect(domain.status).to eq 'inactive'
        expect(domain.blog.present?).to be_falsey
        expect(new_domain.blog.present?).to be_truthy
        expect(new_domain.status).to eq 'active'
        expect(Host.count).to eq 2
        expect(old_host.reason).to eq 'Migration: Uptime'
        expect(old_host.migrated_to).to eq new_domain.host.id
        expect(blog.articles.pluck(:external_id).compact.size).to eq 0
        expect(blog.articles.pluck(:synced_at).compact.size).to eq 0
        expect(blog.articles.pluck(:url).compact.size).to eq 0
        expect(blog.articles.first.publishing_status).to eq 'pending'
        expect(task.status).to eq 'done'

        new_host = Host.last
        expect(new_host.domain).to eq new_domain
        expect(new_host.blog).to eq blog
      end

      it 'should be migrated to same domain' do
        params = {
          migrate_to_new_domain: false,
          blog_type: :wordpress,
          reason: 'Uptime'
        }

        expect(domain.status).to eq 'active'
        expect(domain.blog.present?).to be_truthy
        expect(Host.count).to eq 1
        expect(blog.articles.pluck(:external_id).compact.size).to eq 5
        expect(blog.articles.pluck(:url).compact.size).to eq 5
        expect(blog.articles.pluck(:synced_at).compact.size).to eq 5
        expect(blog.articles.first.publishing_status).to eq 'publish'
        expect(task.status).to eq 'pending'

        service = Migrations::Run.call(domain: domain, params: params, user: user)
        expect(service.success?).to be_truthy

        domain.reload
        blog.reload
        task.reload
        old_host = domain.hosts.first

        expect(domain.status).to eq 'active'
        expect(domain.blog.present?).to be_truthy
        expect(Host.count).to eq 2
        expect(old_host.reason).to eq 'Migration: Uptime'
        expect(old_host.migrated_to).to eq domain.host.id
        expect(blog.articles.pluck(:external_id).compact.size).to eq 0
        expect(blog.articles.pluck(:synced_at).compact.size).to eq 0
        expect(blog.articles.pluck(:url).compact.size).to eq 0
        expect(blog.articles.first.publishing_status).to eq 'pending'
        expect(task.status).to eq 'done'

        new_host = Host.last
        expect(new_host.domain).to eq domain
        expect(new_host.blog).to eq blog
      end
    end
  end
end
