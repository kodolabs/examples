require 'rails_helper'

describe SystemHistories::StoreSystemStatus do
  describe '.call' do
    let!(:user) { create :user }
    let!(:client) { create :client, manager: user }

    let!(:campaign1) { create :campaign, domain: 'google.com', client: client, health: 75 }
    let!(:campaign2) { create :campaign, domain: 'amazon.com', client: client, health: 90 }
    let!(:campaign3) { create :campaign, domain: 'yahoo', client: client, health: 80 }

    let!(:campaigns_service1) do
      create :campaigns_service, campaign: campaign1, service_type: :seo, monthly_spend: 20.5
    end
    let!(:campaigns_service2) do
      create :campaigns_service, campaign: campaign2, service_type: :ppc, monthly_spend: 15.00
    end
    let!(:campaigns_service3) do
      create :campaigns_service, campaign: campaign3, service_type: :social, monthly_spend: 20.00
    end
    let!(:campaigns_service4) do
      create :campaigns_service, campaign: campaign1, service_type: :seo, monthly_spend: 20.5
    end
    let!(:campaigns_service5) do
      create :campaigns_service, campaign: campaign2, service_type: :ppc, monthly_spend: 15.00
    end
    let!(:campaigns_service6) do
      create :campaigns_service, campaign: campaign3, service_type: :social, monthly_spend: 20.00
    end

    context 'should create history' do
      it 'on current week' do
        SystemHistories::StoreSystemStatus.new.call
        expect(SystemHistory.count).to eq 1
        history = SystemHistory.last
        assert_equal history.amounts['seo'], '41.0'
        assert_equal history.amounts['ppc'], '30.0'
        assert_equal history.amounts['social'], '40.0'
        assert_equal history.health.to_i, 81
      end

      it 'on few weeks' do
        SystemHistories::StoreSystemStatus.new.call
        Timecop.freeze(Time.zone.now.beginning_of_week + 7.days)
        SystemHistories::StoreSystemStatus.new.call
        expect(SystemHistory.count).to eq 2

        create(:campaign,
          domain: 'aliexpreses.com',
          client: client,
          health: 40)
        create(:campaigns_service,
          campaign: campaign1,
          service_type: :seo,
          monthly_spend: 5)
        create(
          :campaigns_service,
          campaign: campaign2,
          service_type: :ppc,
          monthly_spend: 7
        )
        create(
          :campaigns_service,
          campaign: campaign3,
          service_type: :social,
          monthly_spend: 9
        )
        SystemHistories::StoreSystemStatus.new.call
        history = SystemHistory.last
        assert_equal history.amounts['seo'], '46.0'
        assert_equal history.amounts['ppc'], '37.0'
        assert_equal history.amounts['social'], '49.0'
        assert_equal history.health.to_i, 71
      end
    end

    context 'should update history' do
      it 'on different days on one week' do
        SystemHistories::StoreSystemStatus.new.call
        Timecop.freeze(Time.zone.now.beginning_of_week + 2.days)
        SystemHistories::StoreSystemStatus.new.call
        expect(SystemHistory.count).to eq 1
      end
    end
  end
end
