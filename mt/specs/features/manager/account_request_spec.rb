require 'rails_helper'

feature 'Account Request page' do
  it 'navigate-able from Welcome landing static page' do
    visit welcome_path
    expect(page).to have_link('Sign up', href: new_manager_account_request_path)
  end

  context 'with valid credentials', js: true do
    it 'should be show successfull message' do
      visit new_manager_account_request_path
      within 'form' do
        fill_in 'First name', with: 'John'
        fill_in 'Last name', with: 'Smith'
        fill_in 'Email', with: 'test@gmail.com'
        fill_in 'Company name', with: 'Healthcare Company'
        find(:css, '.session__checkbox-label').trigger('click')
        click_button 'Sign up'
      end

      find('.sweet-alert').should have_content('Thanks for registering')
    end
  end

  context 'with unchecked Terms', js: true do
    it 'should show message' do
      visit new_manager_account_request_path
      click_button 'Sign up'
      within '.terms-error' do
        expect(page).to have_content 'You must agree with the terms and conditions'
      end
    end
  end

  context 'with invalid credentials', js: true do
    it 'should fail' do
      visit new_manager_account_request_path
      find(:css, '.session__checkbox-label').trigger('click')
      click_button 'Sign up'

      expect(page).to have_selector '.field.first_name .sign_up_error'
      expect(page).to have_selector '.field.last_name .sign_up_error'
      expect(page).to have_selector '.field.email .sign_up_error'
      expect(page).to have_selector '.field.company_name .sign_up_error'
    end
  end
end
