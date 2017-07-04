require 'rails_helper'

feature 'Notifications' do
  let(:redis) { Redis.new }

  before do
    3.times { Notification.create }
    user_sign_in
  end

  describe 'should reset notification counter' do
    it 'when clicking on icon bell', :js do
      visit root_path
      within('span.badge-danger') do
        expect(page).to have_content '3'
      end
      click_link('notifications-link')
      visit domains_path
      expect(page).to have_no_css('.badge-danger')
    end
  end
end
