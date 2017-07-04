require 'rails_helper'

feature 'Clients' do
  let!(:user) { create :user }
  before { user_sign_in user }

  describe 'page' do
    context 'without clients' do
      it 'should show empty message' do
        visit clients_path
        expect(page).to have_content 'No clients found'
      end
    end
  end

  describe 'index page' do
    before do
      @client1 = create(:client, manager: user).decorate
      @client2 = create(:client, manager: user).decorate
      @client3 = create(:client, :inactive, manager: user).decorate
      @client4 = create(:client, :inactive, manager: user).decorate
    end

    context 'with active clients' do
      before { visit clients_path }

      it 'should show list' do
        expect(page).to have_content @client1.name
        expect(page).to have_content @client1.email
        expect(page).to have_content @client1.formated_phone
        expect(page).to have_content @client2.name
        expect(page).to have_content @client2.email
        expect(page).to have_content @client2.formated_phone
        expect(page).to have_content 'Showing all 2 clients'
      end

      it 'should find client by name' do
        fill_in 'Search', with: @client1.name
        find(:css, '.clients-search-button').click
        expect(page).to have_content @client1.name
        expect(page).to_not have_content @client2.name
      end

      it 'should find client by email' do
        fill_in 'Search', with: @client1.email
        find(:css, '.clients-search-button').click
        expect(page).to have_content @client1.name
        expect(page).to_not have_content @client2.name
      end

      it 'should find client by phone' do
        fill_in 'Search', with: @client1.phone
        find(:css, '.clients-search-button').click
        expect(page).to have_content @client1.name
        expect(page).to_not have_content @client2.name
      end
    end

    context 'with inactive clients' do
      before { visit inactive_clients_path }

      it 'should show list' do
        expect(page).to have_content @client3.name
        expect(page).to have_content @client3.email
        expect(page).to have_content @client3.formated_phone
        expect(page).to have_content @client4.name
        expect(page).to have_content @client4.email
        expect(page).to have_content @client4.formated_phone
        expect(page).to have_content 'Showing all 2 clients'
      end

      it 'should find client by name' do
        fill_in 'Search', with: @client3.name
        find(:css, '.clients-search-button').click
        expect(page).to have_content @client3.name
        expect(page).to_not have_content @client4.name
      end

      it 'should find client by email' do
        fill_in 'Search', with: @client3.email
        find(:css, '.clients-search-button').click
        expect(page).to have_content @client3.name
        expect(page).to_not have_content @client4.name
      end

      it 'should find client by phone' do
        fill_in 'Search', with: @client3.phone
        find(:css, '.clients-search-button').click
        expect(page).to have_content @client3.name
        expect(page).to_not have_content @client4.name
      end
    end
  end

  describe 'Create page' do
    before { visit new_client_path }

    it 'should save client', :js do
      fill_in 'client_name', with: 'John Doe'
      fill_in 'client_email', with: 'johndoe@example.com'
      fill_in 'client_phone', with: '79781231213'
      fill_in 'client_since', with: '05031991'
      select user.name, from: 'client_manager_id'

      click_button 'Create'
      expect(page).to have_flash I18n.t('notifications.client_created')
    end

    it 'should show error when email format is wrong' do
      fill_in 'client_email', with: 'johndoe@'
      click_button 'Create'
      expect(page).to have_content I18n.t('clients.validation.email_format')
    end

    it 'should save client without since date', :js do
      fill_in 'client_name', with: 'John Doe'
      fill_in 'client_email', with: 'johndoe@example.com'
      fill_in 'client_phone', with: '79781231213'
      select user.name, from: 'client_manager_id'

      click_button 'Create'
      expect(page).to have_flash I18n.t('notifications.client_created')
    end
  end

  describe 'Edit page' do
    before do
      @client = create(:client, manager: user).decorate
      visit edit_client_path(@client)
    end

    it 'should update client' do
      fill_in 'client_name', with: 'Alex Smith'
      fill_in 'client_email', with: 'alexsmith@example.com'
      fill_in 'client_phone', with: '79783334455'
      click_button 'Update'
      @client.reload
      expect(page).to have_flash I18n.t('notifications.client_updated')
      expect(page).to have_content 'Alex Smith'
      expect(page).to have_content 'alexsmith@example.com'
      expect(page).to have_content @client.formated_phone
    end
  end

  describe 'Show page' do
    before do
      @client = create(:client, manager: user).decorate
    end

    it 'should display client info' do
      visit client_path(@client)
      expect(page).to have_content @client.name
      expect(page).to have_content @client.email
      expect(page).to have_content @client.formated_phone
      expect(page).to have_content I18n.l(@client.since, format: :long)
      expect(page).to have_content @client.manager.name
      expect(page).to have_content @client.notes
      expect(page).to have_selector(:link_or_button, I18n.t('clients.show.edit'))
    end

    it 'should display client info if user is tech' do
      user.tech!
      visit client_path(@client)
      expect(page).to have_content @client.name
      expect(page).to_not have_content @client.email
      expect(page).to_not have_content @client.formated_phone
      expect(page).to_not have_content I18n.l(@client.since, format: :long)
      expect(page).to have_content @client.manager.name
      expect(page).to_not have_content @client.notes
    end
  end

  describe 'Activate \ deactivate' do
    before do
      @client = create(:client, manager: user).decorate
      @campaigns = create_list :campaign, 5, active: true, client: @client
    end

    it 'should be deactivated and all campaigns' do
      visit client_path(@client)

      expect(@client.active).to be_truthy
      @campaigns.each do |campaign|
        expect(page).to have_content campaign.domain
      end

      expect(page).to have_selector('table.campaigns tbody tr', count: 5)
      expect(page).to have_selector('table.campaigns tbody .glyphicon-ok-sign', count: 5)

      expect(page).to have_content I18n.t('clients.deactivate')
      expect(@client.cancelled_at.present?).to be_falsey
      click_link I18n.t('clients.deactivate')
      expect(current_path).to eq clients_path

      expect(page).to have_flash I18n.t('notifications.client_deactivated')

      @client.reload
      expect(@client.active).to be_falsey
      expect(@client.cancelled_at.present?).to be_truthy
      visit client_path(@client)
      expect(page).to have_selector('table.campaigns tbody .glyphicon-ban-circle', count: 5)
      expect(page).to_not have_content I18n.t('clients.deactivate')
    end

    it 'should be activate' do
      @client.update(active: false, cancelled_at: Time.zone.now)

      visit client_path(@client)
      expect(page).to have_content I18n.t('clients.activate')
      click_link I18n.t('clients.activate')
      @client.reload
      expect(@client.cancelled_at.present?).to be_falsey
      expect(current_path).to eq client_path(@client)

      expect(page).to have_flash I18n.t('notifications.client_activated')
    end
  end
end
