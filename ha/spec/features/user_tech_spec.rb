require 'rails_helper'

feature 'User tech' do
  let!(:user) { create :user, role: :tech }
  let!(:client) { create :client }
  let!(:campaign) { create :campaign, client: client, active: true }
  before { user_sign_in user }

  describe 'clients section' do
    it "can't add new client and didn't seen buttons" do
      visit clients_path

      expect(page).to_not have_content I18n.t('clients.add')
      expect(page).to_not have_content I18n.t('clients.phone')

      visit new_client_path
      expect(current_path).to eq root_path
      expect(page).to have_flash I18n.t('notifications.access_denied')
    end

    it 'show client page' do
      visit client_path(client)

      expect(page).to have_content(client.name)
      expect(page).to_not have_content(client.email)
      expect(page).to_not have_content(client.decorate.formated_phone)
      expect(page).to_not have_content(I18n.l(client.since, format: :long))

      expect(page).to_not have_selector(:link_or_button, I18n.t('clients.show.edit'))
      expect(page).to_not have_content I18n.t('clients.deactivate')
      expect(page).to_not have_content I18n.t('campaigns.create.breadcrumb')

      expect(page.find('#datatable_wrapper')).to have_content campaign.domain
      expect(page).to have_selector('#datatable_wrapper td.links')
      expect(page).to have_selector('#datatable_wrapper td.health')
      expect(page).to_not have_selector('#datatable_wrapper td.edit')
    end

    it 'can not open edit client page' do
      visit edit_client_path(client)

      expect(current_path).to eq root_path
      expect(page).to have_flash I18n.t('notifications.access_denied')
    end

    it 'can not add new campaign' do
      visit new_client_campaign_path(client)

      expect(current_path).to eq root_path
      expect(page).to have_flash I18n.t('notifications.access_denied')
    end

    it 'can not edit campaign' do
      visit edit_client_campaign_path(client, campaign)

      expect(current_path).to eq root_path
      expect(page).to have_flash I18n.t('notifications.access_denied')
    end

    it 'can show client campaign' do
      visit client_campaign_path(client, campaign)
      expect(current_path).to eq client_campaign_path(client, campaign)

      expect(page).to_not have_content I18n.t('campaigns.show.edit')
      expect(page).to have_content I18n.t('campaigns.general')
      expect(page).to have_content I18n.t('campaigns.client')
      expect(page).to have_content I18n.t('campaigns.brand')

      expect(page).to have_content I18n.t('campaigns.show.links')
      expect(page).to have_content I18n.t('campaigns.show.available_resources')
    end
  end

  describe 'campaigns section' do
    it 'campaign listing should not show seo details' do
      visit campaigns_path

      expect(page).to have_selector('table.campaigns tbody tr', count: 1)
      expect(page).to have_selector('table.campaigns tbody td.links')
      expect(page).to have_selector('table.campaigns tbody td.health')
      expect(page).to_not have_selector('table.campaigns tbody td.edit')
      expect(page).to_not have_content I18n.t('campaigns.new_campaign')
    end

    it 'can not add new campaign' do
      visit new_campaign_path

      expect(current_path).to eq root_path
      expect(page).to have_flash I18n.t('notifications.access_denied')
    end

    it 'can show campaign' do
      visit campaign_path(campaign)
      expect(current_path).to eq campaign_path(campaign)

      expect(page).to_not have_content I18n.t('campaigns.show.edit')
      expect(page).to have_content I18n.t('campaigns.general')
      expect(page).to have_content I18n.t('campaigns.client')
      expect(page).to have_content I18n.t('campaigns.brand')

      expect(page).to have_content I18n.t('campaigns.show.links')
      expect(page).to have_content I18n.t('campaigns.show.available_resources')
    end

    it 'can not edit campaign' do
      visit edit_campaign_path(campaign)

      expect(current_path).to eq root_path
      expect(page).to have_flash I18n.t('notifications.access_denied')
    end
  end

  describe 'users section' do
    it 'can not show users' do
      visit users_path

      expect(current_path).to eq root_path
      expect(page).to have_flash I18n.t('notifications.access_denied')
    end

    it 'can not add new user' do
      visit new_user_path

      expect(current_path).to eq root_path
      expect(page).to have_flash I18n.t('notifications.access_denied')
    end

    it 'can not edit user' do
      visit edit_user_path(user)

      expect(current_path).to eq root_path
      expect(page).to have_flash I18n.t('notifications.access_denied')
    end
  end
end
