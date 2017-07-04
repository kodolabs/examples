require 'rails_helper'

feature 'Campaigns' do
  let!(:user) { create :user }
  let!(:client) { create :client, manager: user }
  let!(:network1) { create :network }
  let!(:network2) { create :network }

  before { user_sign_in user }

  describe 'list' do
    let!(:client1) { create :client, manager: user, name: 'John Doe' }
    let!(:client2) { create :client, manager: user, name: 'Bob Voe' }
    let!(:campaign1) do
      create :campaign, domain: 'google.com', client: client1, started_at: Time.zone.now
    end
    let!(:campaign2) do
      create :campaign, domain: 'amazon.com', client: client2, started_at: Time.zone.now - 5.days
    end
    let!(:campaign3) do
      create :campaign, domain: 'yahoo.com', client: client1, started_at: Time.zone.now - 5.days,
                        active: false
    end

    describe 'inactive list' do
      before do
        visit inactive_campaigns_path
        @campaigns = page.all('table.campaigns tbody tr')
      end

      it 'should only inactive campaigns' do
        expect(page).to have_content campaign3.domain
        expect(page).not_to have_content campaign1.domain
        expect(page).not_to have_content campaign2.domain
      end
    end

    before do
      visit campaigns_path
      @campaigns = page.all('table.campaigns tbody tr')
    end

    describe 'active list' do
      it 'should show in order' do
        expect(@campaigns[0]).to have_content campaign1.domain
        expect(@campaigns[1]).to have_content campaign2.domain
        expect(@campaigns[2]).not_to have_content campaign3.domain
      end

      it 'should ordered by name desc' do
        page.find('th.title a.remote-sort').click
        page.find('th.title a.remote-sort').click
        expect(@campaigns[1]).to have_content campaign2.domain
        expect(@campaigns[0]).to have_content campaign1.domain
      end

      it 'should ordered by client desc' do
        page.find('th.client a.remote-sort').click
        expect(@campaigns[1]).to have_content campaign2.domain
        expect(@campaigns[0]).to have_content campaign1.domain
      end

      it 'should ordered by period desc' do
        page.find('th.period a.remote-sort').click
        expect(@campaigns[1]).to have_content campaign2.domain
        expect(@campaigns[0]).to have_content campaign1.domain
      end
    end

    describe 'search' do
      it 'should search by campaign' do
        fill_in 'Search', with: 'google.com'
        page.find('.submit-search').click
        expect(page).to have_content 'google.com'
        expect(page).not_to have_content 'amazon.com'
      end

      it 'should search by client name' do
        fill_in 'Search', with: 'Bob Voe'
        page.find('.submit-search').click
        expect(page).to have_content 'Bob Voe'
        expect(page).not_to have_content 'John Doe'
      end
    end
  end

  describe 'create from index' do
    it 'should successfully create a campaign', js: true do
      visit new_campaign_path
      select_option('client_id', client.name, 'input')
      expect(page).to have_content I18n.t('campaigns.new.title')
      fill_in 'campaign_domain', with: 'www.example.com'
      find(:css, '#campaign_seo').set(true)
      fill_in 'campaign_seo_amount', with: 100
      select_option('campaign_network_ids', network1.title, 'select')
      find(:css, "label[for='campaign_brand_epik'] .collection_radio_buttons").click
      fill_in 'campaign_contract_period', with: 10
      fill_in 'campaign_started_at', with: '10/11/2017'
      fill_in 'campaign_comment', with: 'Test comment'
      click_button 'Create'
      expect(page).to have_flash I18n.t('notifications.campaign_created')
      expect(page).to have_content 'www.example.com'
      expect(page).to have_content 'Test comment'
    end

    it 'should show fail with wrong domain', js: true do
      visit new_campaign_path
      select_option('client_id', client.name, 'input')
      expect(page).to have_content I18n.t('campaigns.new.title')
      fill_in 'campaign_domain', with: 'example'
      find(:css, '#campaign_seo').set(true)
      fill_in 'campaign_seo_amount', with: 100
      select_option('campaign_network_ids', network1.title, 'select')
      find(:css, "label[for='campaign_brand_epik'] .collection_radio_buttons").click
      fill_in 'campaign_contract_period', with: 10
      fill_in 'campaign_started_at', with: '10/11/2017'
      fill_in 'campaign_comment', with: 'Test comment'
      click_button 'Create'
      expect(page).to have_content 'Invalid domain name: example'
    end
  end

  describe 'edit page from index' do
    it 'should successfully edit a campaign', js: true do
      campaign = create :campaign, domain: 'google.com', client: client, comment: 'Test comment'
      new_client = create :client, manager: user

      visit campaigns_path
      expect(page).to have_content campaign.domain

      visit edit_campaign_path(campaign)
      select_option('client_id', new_client.name, 'input')
      fill_in 'campaign_domain', with: 'www.example.com'
      find(:css, '#campaign_seo').set(true)
      fill_in 'campaign_seo_amount', with: 100
      select_option('campaign_network_ids', network1.title, 'select')
      fill_in 'campaign_contract_period', with: 10
      fill_in 'campaign_started_at', with: '10/11/2017'
      fill_in 'campaign_comment', with: 'Edited comment'
      click_button 'Update'

      expect(page).to have_flash I18n.t('notifications.campaign_updated')
      expect(page).to have_content 'www.example.com'
      expect(page).to have_content 'Edited comment'
      expect(page).to have_content new_client.name
    end

    it 'should display validation message if networks is not selected' do
      campaign = create :campaign, domain: 'google.com', client: client

      visit edit_campaign_path(campaign)
      fill_in 'campaign_domain', with: 'www.example.com'
      find(:css, '#campaign_seo').set(true)
      fill_in 'campaign_seo_amount', with: 100
      fill_in 'campaign_contract_period', with: 10
      fill_in 'campaign_started_at', with: '10/11/2017'
      click_button 'Update'
      expect(page).to have_content "can't be blank"
    end
  end

  describe 'create from client page' do
    it 'should successfully create a company' do
      visit client_path(client)
      click_on 'Create'
      expect(page).to have_content I18n.t('campaigns.new.title')
      fill_in 'campaign_domain', with: 'www.example.com'
      find(:css, '#campaign_seo').set(true)
      fill_in 'campaign_seo_amount', with: 100
      select network1.title, from: 'campaign_network_ids'
      fill_in 'campaign_contract_period', with: 10
      fill_in 'campaign_started_at', with: '10/11/2017'
      click_button 'Create'
      expect(page).to have_flash I18n.t('notifications.campaign_created')
      expect(page).to have_content 'www.example.com'
    end

    it 'should display validation message if networks is not selected' do
      visit new_client_campaign_path(client)
      fill_in 'campaign_domain', with: 'www.example.com'
      find(:css, '#campaign_seo').set(true)
      fill_in 'campaign_seo_amount', with: 100
      fill_in 'campaign_contract_period', with: 10
      fill_in 'campaign_started_at', with: '10/11/2017'
      click_button 'Create'
      expect(page).to have_content "can't be blank"
    end

    it 'should display validation message if services is not selected' do
      visit new_client_campaign_path(client)
      fill_in 'campaign_domain', with: 'www.example.com'
      select network1.title, from: 'campaign_network_ids'
      fill_in 'campaign_contract_period', with: 10
      fill_in 'campaign_started_at', with: '10/11/2017'
      click_button 'Create'
      expect(page).to have_content I18n.t('campaigns.validation.services')
    end

    it 'should display validation message if one of service is selected and amount blank' do
      visit new_client_campaign_path(client)
      fill_in 'campaign_domain', with: 'www.example.com'
      find(:css, '#campaign_seo').set(true)
      select network1.title, from: 'campaign_network_ids'
      fill_in 'campaign_contract_period', with: 10
      fill_in 'campaign_started_at', with: '10/11/2017'
      click_button 'Create'
      expect(page).to have_content "can't be blank"
    end

    it 'should display client campaigns table' do
      list = create_list :campaign, 3, client: client
      visit client_path(client)

      expect(page).to have_selector('table.campaigns tbody tr', count: 3)
      list.each do |campaign|
        expect(page).to have_content campaign.domain
        expect(page).to have_content campaign.started_at.to_s(:short)
      end
    end
  end

  describe 'edit page from client' do
    it 'should successfully edit a campaign' do
      campaign = create :campaign, domain: 'google.com', client: client

      visit client_path(client)
      expect(page).to have_content campaign.domain

      visit edit_client_campaign_path(id: campaign.id, client_id: client.id)
      fill_in 'campaign_domain', with: 'www.example.com'
      find(:css, '#campaign_seo').set(true)
      fill_in 'campaign_seo_amount', with: 100
      select network1.title, from: 'campaign_network_ids'
      fill_in 'campaign_contract_period', with: 10
      fill_in 'campaign_started_at', with: '10/11/2017'
      click_button 'Update'

      expect(page).to have_flash I18n.t('notifications.campaign_updated')
      expect(page).to have_content 'www.example.com'
    end

    it 'should display validation message if networks is not selected' do
      campaign = create :campaign, domain: 'google.com', client: client

      visit edit_client_campaign_path(id: campaign.id, client_id: client.id)
      fill_in 'campaign_domain', with: 'www.example.com'
      find(:css, '#campaign_seo').set(true)
      fill_in 'campaign_seo_amount', with: 100
      fill_in 'campaign_contract_period', with: 10
      fill_in 'campaign_started_at', with: '10/11/2017'
      click_button 'Update'
      expect(page).to have_content "can't be blank"
    end
  end
end
