require 'rails_helper'

feature 'Manager payments' do
  let!(:manager)   { create :manager }
  let!(:hospital)  { create :hospital, manager: manager }

  before { manager_sign_in manager }

  context 'view' do
    it 'should show bookings' do
      visit manager_payments_path
      expect(page).to have_content 'Payments not found'
      expect(page).to have_css 'a.dashboard-nav__link--active', text: 'Payments'
    end
  end
end
