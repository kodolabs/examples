require 'rails_helper'

feature 'Static Legal pages' do
  context 'Privacy Policy' do
    it 'navigate-able from homepage' do
      visit root_path
      expect(page).to have_link('Privacy Policy', href: privacy_policy_path)
    end
  end

  context 'Terms of Service page' do
    it 'navigate-able from homepage' do
      visit root_path
      expect(page).to have_link('Terms of Service', href: terms_of_service_path)
    end
  end
end
