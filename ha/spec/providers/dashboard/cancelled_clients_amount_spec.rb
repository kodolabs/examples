require 'rails_helper'

describe Dashboard::CancelledClientsAmountProvider do
  let!(:user) { create :user }

  let!(:client1) { create :client, manager: user }
  let!(:client2) { create :client, manager: user, active: false }
  let!(:client3) { create :client, manager: user, active: false }

  let!(:campaign1) { create :campaign, domain: 'google.com', client: client1 }
  let!(:campaign2) { create :campaign, domain: 'amazon.com', client: client2 }
  let!(:campaign3) { create :campaign, domain: 'yahoo', client: client3 }

  let!(:campaigns_service1) do
    create :campaigns_service, campaign: campaign1, service_type: :seo, monthly_spend: 20.5
  end
  let!(:campaigns_service2) do
    create :campaigns_service, campaign: campaign2, service_type: :ppc, monthly_spend: 15.00
  end
  let!(:campaigns_service3) do
    create :campaigns_service, campaign: campaign3, service_type: :social, monthly_spend: 25.00
  end

  before { Rails.cache.clear }

  describe 'Cancelled clients' do
    it 'should return campaigns amount only with inactive clients' do
      sum = [
        campaigns_service2,
        campaigns_service3
      ].sum(&:monthly_spend)
      assert_equal sum.to_i, Dashboard::CancelledClientsAmountProvider.new.call.to_i
    end

    it 'should recalculate clients after active false status' do
      client1.update(active: false)
      sum = [
        campaigns_service1,
        campaigns_service2,
        campaigns_service3
      ].sum(&:monthly_spend)
      assert_equal sum.to_i, Dashboard::CancelledClientsAmountProvider.new.call.to_i
    end
  end
end
