require 'rails_helper'

feature 'Dashboard home page' do
  let!(:host) { create :host, active: true }

  let!(:blog1) { create :blog, host: host }
  let!(:blog2) { create :blog }

  let!(:client1) { create :client, name: 'James', created_at: Time.zone.now + 3.days }
  let!(:client2) { create :client, name: 'Corey', created_at: Time.zone.now + 5.days }
  let!(:client3) { create :client, name: 'Will', created_at: Time.zone.now }

  let!(:article1) { create :article, blog: blog1 }
  let!(:article2) { create :article, blog: blog1 }
  let!(:article3) { create :article, blog: blog1 }
  let!(:article4) { create :article, blog: blog1 }
  let!(:article5) { create :article, blog: blog1 }

  let!(:campaign1) { create :campaign, domain: 'google.com', client: client1 }
  let!(:campaign2) { create :campaign, domain: 'amazon.com', client: client2 }
  let!(:campaign3) { create :campaign, domain: 'yahoo.com', client: client3 }

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
  let!(:amounts) { { seo: 50.2, ppc: 25.3, social: 42.5 } }
  let!(:system_history) { create :system_history, amounts: amounts, health: 70 }

  before { Rails.cache.clear }

  describe 'blogs' do
    it 'should show number of clients, blobs & articles' do
      user_sign_in
      visit root_path
      expect(page).to have_content '3 Clients'
      expect(page).to have_content '1 Blog'
      expect(page).to have_content '5 Articles'
    end

    it 'should not show content when user not admin' do
      create :user, role: :tech
      visit root_path

      expect(page).not_to have_content '3 Clients'
      expect(page).not_to have_content '1 Blog'
      expect(page).not_to have_content '5 Articles'
    end
  end

  describe 'dashboard header' do
    before do
      client = create :client, name: 'John', active: false
      campaign = create :campaign, domain: 'facebook.com', client: client, active: false
      create :campaigns_service, campaign: campaign, service_type: :seo, monthly_spend: 31.25
      create :campaigns_service, campaign: campaign, service_type: :social, monthly_spend: 76.06
      user_sign_in
      visit root_path
    end

    it 'should show stats' do
      total_revenue = find('p', text: I18n.t('dashboard.total_revenue')).find(:xpath, '../..')
      expect(total_revenue).to have_content '$118'
      network_health = find('p', text: I18n.t('dashboard.network_health')).find(:xpath, '../..')
      expect(network_health).to have_content '70%'
      active_clients = find('p', text: I18n.t('dashboard.active_clients')).find(:xpath, '../..')
      expect(active_clients).to have_content '3'
      cancelled_clients = find('p', text: I18n.t('dashboard.cancelled_clients')).find(:xpath, '../..')
      expect(cancelled_clients).to have_content '$107 / 1'
    end
  end

  describe 'recently added clients list' do
    before do
      user_sign_in
      visit root_path
      @clients = page.all('table.added_clients tbody tr')
    end

    it 'should show in order' do
      expect(@clients[0]).to have_content client2.name
      expect(@clients[1]).to have_content client1.name
      expect(@clients[2]).to have_content client3.name
    end

    it 'should calculate amounts' do
      expect(@clients[0]).to have_content '$27.00'
      expect(@clients[1]).to have_content '$37.20'
      expect(@clients[2]).to have_content '$107.31'
    end
  end

  describe 'recently cancelled clients list' do
    before do
      client1.update(active: false, cancelled_at: Time.zone.now)
      client2.update(active: false, cancelled_at: Time.zone.now - 5.days)
      campaign1.update(active: false)
      campaign2.update(active: false)
      user_sign_in
      visit root_path
      @clients = page.all('table.cancelled_clients tbody tr')
    end

    it 'should show in order' do
      expect(@clients[0]).to have_content client1.name
      expect(@clients[1]).to have_content client2.name
    end

    it 'should calculate amounts' do
      expect(@clients[0]).to have_content '$37.20'
      expect(@clients[1]).to have_content '$27.00'
      expect(@clients[2]).not_to have_content '$107.31'
    end
  end
end
