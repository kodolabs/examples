require 'rails_helper'

RSpec.describe Domain, type: :model do
  describe 'activate' do
    it 'should set active status and activated_at date' do
      domain = create :domain, status: :pending

      expect(domain.status).to eq 'pending'
      expect(domain.activated_at).to be_nil

      domain.activate!
      domain.reload

      expect(domain.status).to eq 'active'
      expect(domain.activated_at.to_s).to eq Time.zone.now.to_s
    end

    it 'should set active status and activated_at date' do
      datetime = Time.zone.now
      domain = create :domain, status: :pending, activated_at: datetime

      expect(domain.status).to eq 'pending'
      expect(domain.activated_at.to_s).to eq datetime.to_s

      domain.activate!
      domain.reload

      expect(domain.status).to eq 'active'
      expect(domain.activated_at.to_s).to eq datetime.to_s
    end
  end

  describe 'not indexed' do
    it 'check count of days' do
      domain = create :domain, status: :pending
      monitoring = domain.monitorings.indexed.first

      expect(domain.index_unknown?).to be_truthy
      expect(domain.not_indexed_days).to eq 0

      domain.indexed!

      expect(domain.indexed?).to be_truthy
      expect(domain.not_indexed_days).to eq 0

      domain.not_indexed!
      monitoring.update(last_status_changed_at: Time.zone.today)

      expect(domain.not_indexed?).to be_truthy
      expect(domain.not_indexed_days).to eq 0

      monitoring.update(last_status_changed_at: Time.zone.today - 2.days)
      domain.reload

      expect(domain.not_indexed_days).to eq 2
    end
  end

  describe 'is live' do
    it 'check' do
      domain_pending = create :domain, status: :pending
      domain_active = create :domain, status: :active
      domain_quarantine = create :domain, status: :quarantine
      domain_zombie = create :domain, status: :zombie
      domain_inactive = create :domain, status: :inactive

      expect(domain_pending.live?).to be_truthy
      expect(domain_active.live?).to be_truthy
      expect(domain_quarantine.live?).to be_truthy
      expect(domain_zombie.live?).to be_truthy
      expect(domain_inactive.live?).to be_falsey
    end
  end
end
