require 'rails_helper'

describe Dashboard::CancelledClientsProvider do
  let!(:user) { create :user }

  let!(:client1) { create :client, name: 'James', active: false, cancelled_at: Time.zone.now + 5.days }
  let!(:client2) { create :client, name: 'Corey', active: false, cancelled_at: Time.zone.now + 3.days }
  let!(:client3) { create :client, name: 'Will', active: false, cancelled_at: Time.zone.now }

  let!(:campaign1) { create :campaign, domain: 'google.com', client: client1, active: false }
  let!(:campaign2) { create :campaign, domain: 'amazon.com', client: client2, active: false }
  let!(:campaign3) { create :campaign, domain: 'yahoo', client: client3, active: false }

  let!(:campaigns_service1) do
    create :campaigns_service, campaign: campaign1, service_type: :ppc, monthly_spend: 20.5
  end
  let!(:campaigns_service2) do
    create :campaigns_service, campaign: campaign1, service_type: :social, monthly_spend: 16.7
  end
  let!(:campaigns_service3) do
    create :campaigns_service, campaign: campaign2, service_type: :seo, monthly_spend: 15.00
  end
  let!(:campaigns_service4) do
    create :campaigns_service, campaign: campaign2, service_type: :ppc, monthly_spend: 12.00
  end
  let!(:campaigns_service5) do
    create :campaigns_service, campaign: campaign3, service_type: :seo, monthly_spend: 31.25
  end
  let!(:campaigns_service6) do
    create :campaigns_service, campaign: campaign3, service_type: :social, monthly_spend: 76.06
  end

  before do
    Rails.cache.clear
  end

  describe 'Recently Cancelled clients' do
    it 'should return campaigns amount only with deactivated clients' do
      clients = Dashboard::CancelledClientsProvider.new.call
      sum1 = [
        campaigns_service1,
        campaigns_service2
      ].sum(&:monthly_spend)
      sum2 = [
        campaigns_service3,
        campaigns_service4
      ].sum(&:monthly_spend)
      sum3 = [
        campaigns_service5,
        campaigns_service6
      ].sum(&:monthly_spend)

      expect(clients[0][:amount].to_i).to eq sum1.to_i
      expect(clients[1][:amount].to_i).to eq sum2.to_i
      expect(clients[2][:amount].to_i).to eq sum3.to_i
    end

    it 'should not include deactivated clients' do
      client1.update(active: true)
      clients = Dashboard::CancelledClientsProvider.new.call
      sum1 = [
        campaigns_service1,
        campaigns_service2
      ].sum(&:monthly_spend)
      sum2 = [
        campaigns_service3,
        campaigns_service4
      ].sum(&:monthly_spend)
      sum3 = [
        campaigns_service5,
        campaigns_service6
      ].sum(&:monthly_spend)

      expect(clients[0][:amount].to_i).not_to eq sum1.to_i
      expect(clients[0][:amount].to_i).to eq sum2.to_i
      expect(clients[1][:amount].to_i).to eq sum3.to_i
    end
  end
end
