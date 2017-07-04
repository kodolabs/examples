require 'rails_helper'

feature 'User' do
  let!(:user) { create :user }
  let(:invited_user_mail) { user.invite!(user) }

  describe 'invitation' do
    it 'can send an email with login link' do
      expect { invited_user_mail }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe 'with received email' do
    before do
      path_regex = %r{(?:"https?\:\/\/.*?)(\/.*?)(?:")}
      path = invited_user_mail.body.encoded.match(path_regex)[1]
      visit(path)
    end

    it 'can set password and authorized' do
      fill_in 'Password', with: 'password'
      fill_in 'Confirm Password', with: 'password'
      click_button 'Set my password'
      expect(page).to have_content 'Your password was set successfully. You are now signed in.'
      expect(page).to have_content 'Logout'
    end

    it 'should fail' do
      fill_in 'Password', with: 'password'
      fill_in 'Confirm Password', with: 'wrong_password'
      click_button 'Set my password'
      expect(page).to have_content "doesn't match Password"
    end
  end
end
