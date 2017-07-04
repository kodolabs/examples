require 'rails_helper'

feature 'Host Deactivation' do
  let!(:domain) { create :domain, name: 'google.com', status: :active }
  let!(:blog) { create :blog }
  let!(:host) { create :host, domain: domain, blog: blog, active: true }

  before do
    user_sign_in
  end

  describe 'deactivate' do
    it 'should successfully deactivate host' do
      visit domain_host_deactivations_path(domain)
      find(:css, "label[for='host_deactivation_status_pending'] .collection_radio_buttons").click
      fill_in 'host_deactivation_reason', with: 'Deactivate'
      click_button 'Deactivate'
      expect(page).to have_flash I18n.t('notifications.host_deactivated')
    end

    it 'should fail when host inactive' do
      host.update(active: false)
      visit domain_host_deactivations_path(domain)
      expect(page).to have_flash I18n.t('notifications.access_denied')
    end
  end
end
