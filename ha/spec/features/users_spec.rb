require 'rails_helper'

feature 'Users' do
  let!(:user1) { create :user, name: 'Alan', role: :account_manager, active: true }
  let!(:user2) { create :user, name: 'Bob', role: :tech, active: true }
  let!(:user3) { create :user, name: 'John', role: :admin, active: true }
  let!(:user4) { create :user, name: 'Daniel', role: :admin, active: false }
  let!(:user5) { create :user, name: 'Anthony', role: :admin, active: false }

  describe 'list' do
    it 'should show active in order' do
      user_sign_in user3
      visit users_path
      expect(page).to have_content user1.name
      expect(page).to have_content user2.name
      expect(page).to have_content user3.name
      expect(page).not_to have_content user4.name
      expect(page).not_to have_content user5.name
    end

    it 'should show inactive in order' do
      user_sign_in user4
      visit inactive_users_path
      expect(page).to have_content user4.name
      expect(page).to have_content user5.name
      expect(page).not_to have_content user1.name
      expect(page).not_to have_content user2.name
      expect(page).not_to have_content user3.name
    end
  end

  describe 'create page' do
    before do
      user_sign_in user3
      visit new_user_path
    end

    it 'admin should create user' do
      fill_in 'create_email', with: 'johndoe@example.com'
      fill_in 'create_name', with: 'John Doe'
      fill_in 'create_password', with: '79781231213'
      choose I18n.t('users.roles.admin')

      click_button 'Create'
      expect(page).to have_flash I18n.t('notifications.user_created')
    end

    it 'should fail create user' do
      click_button 'Create'
      expect(page).to have_content "can't be blank"
    end

    it 'should show error when email format is wrong' do
      fill_in 'create_email', with: 'johndoe@'
      click_button 'Create'
      expect(page).to have_content I18n.t('users.validation.email_format')
    end

    it 'should fail with non uniq email' do
      fill_in 'create_email', with: user3.email
      fill_in 'create_name', with: 'John Doe'
      fill_in 'create_password', with: '79781231213'
      choose I18n.t('users.roles.admin')

      click_button 'Create'
      expect(page).to have_content I18n.t('users.validation.email_non_uniq')
    end
  end

  describe 'update page' do
    before do
      user_sign_in user3
      visit edit_user_path(user1)
    end

    it 'should update user' do
      fill_in 'edit_email', with: 'johndoe@example.com'
      fill_in 'edit_name', with: 'John Doe'
      fill_in 'edit_password', with: '79781231213'
      choose I18n.t('users.roles.admin')
      click_button 'Update'
      expect(page).to have_flash I18n.t('notifications.user_updated')
    end

    it 'should update user without password' do
      fill_in 'edit_email', with: 'johndoe@example.com'
      fill_in 'edit_name', with: 'John Doe'
      choose I18n.t('users.roles.admin')
      click_button 'Update'
      expect(page).to have_flash I18n.t('notifications.user_updated')
    end
  end
end
