require 'rails_helper'

feature 'Welcome' do
  context 'success' do
    let(:user) { create(:user, confirmed_at: nil) }
    specify 'send email' do
      visit welcome_users_path
      expect(page).to have_content 'Great to have you on board'
      fill_in 'user_email', with: user.email
      click_on 'Resend'
      expect(page).to have_content 'Login'
    end
  end

  context 'fail' do
    let(:user) { create(:user, confirmed_at: Time.current - 10.minutes) }
    specify 'invalid mail' do
      visit welcome_users_path
      expect(page).to have_content 'Great to have you on board'
      fill_in 'user_email', with: rand(1..5)
      click_on 'Resend'
      expect(page).to have_content 'Email not found'
    end

    specify 'already confirmed' do
      visit welcome_users_path
      expect(page).to have_content 'Great to have you on board'
      fill_in 'user_email', with: user.email
      click_on 'Resend'
      expect(page).to have_content 'Email was already confirmed, please try signing in'
    end
  end
end
