require 'rails_helper'

describe Migrations::CreateHost do
  let!(:user) { create :user }
  let!(:domain) { create :domain, name: 'google.com', status: :active }
  let!(:blog) { create :blog }
  let!(:host) { create :host, domain: domain, blog: blog, active: true }

  describe '.call' do
    context 'success migrate to new domain' do
      it 'should create new host, deactivate old and update domain statuses' do
        new_domain = create :domain, name: 'facebook.com', status: :pending
        params = {
          migrate_to_new_domain: true,
          blog_type: :wordpress,
          domain_id: new_domain.id,
          reason: 'Uptime',
          status: :inactive
        }

        Migrations::CreateHost.call(domain: domain, params: params, user: user)
        new_host = new_domain.host
        expect(new_host.domain).to eq new_domain
        expect(new_host.blog).to eq blog

        old_host = domain.hosts.first
        expect(old_host.reason).to eq 'Migration: Uptime'
        expect(old_host.migrated_to).to eq new_host.id
        expect(old_host.active).to eq false

        domain.reload
        expect(domain.status).to eq 'inactive'
        expect(domain.blog.present?).to be_falsey

        new_domain.reload
        expect(new_domain.blog.present?).to be_truthy
        expect(new_domain.status).to eq 'active'
      end
    end

    context 'success migrate to same domain' do
      it 'should create new host, deactivate old' do
        params = {
          migrate_to_new_domain: false,
          blog_type: :wordpress,
          reason: 'Uptime'
        }

        Migrations::CreateHost.call(domain: domain, params: params, user: user)
        domain.reload
        new_host = domain.host
        expect(new_host.domain).to eq domain
        expect(new_host.blog).to eq blog

        old_host = domain.hosts.first
        expect(old_host.reason).to eq 'Migration: Uptime'
        expect(old_host.migrated_to).to eq new_host.id
        expect(old_host.active).to eq false

        expect(domain.status).to eq 'active'
        expect(domain.blog.present?).to be_truthy
        expect(Domain.count).to eq 1
      end
    end
  end
end
