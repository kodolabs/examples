require 'rails_helper'

feature 'User Sign Up' do
  context 'when js enabled' do
    before { visit '/' }

    context 'with valid credentials' do
      it 'should be show successfull message', js: true do
        click_link 'Sign Up'
        expect(current_path).to eq '/'

        within 'form.new_user' do
          fill_in 'First name', with: 'John'
          fill_in 'Last name', with: 'Smith'
          fill_in 'Email', with: 'test@gmail.com'
          fill_in 'Password', with: '123123123123'
          fill_in 'Confirm password', with: '123123123123'
          click_on 'Sign up'
        end

        expect(page).to have_content 'Logout'
      end
    end

    context 'with invalid credentials' do
      it 'should fail', js: true do
        click_link 'Sign Up'
        expect(current_path).to eq '/'

        within 'form.new_user' do
          click_on 'Sign up'
        end

        expect(page).to have_selector '.field.first_name .sign_up_error'
        expect(page).to have_selector '.field.last_name .sign_up_error'
        expect(page).to have_selector '.field.email .sign_up_error'
        expect(page).to have_selector '.field.password .sign_up_error'
        expect(page).not_to have_selector '.field.password_confirmation .sign_up_error'
      end
    end
  end

  context 'when js not available' do
    context 'with valid credentials' do
      it 'should be show successfull message' do
        visit new_user_registration_path
        within 'form.new_user' do
          fill_in 'First name', with: 'John'
          fill_in 'Last name', with: 'Smith'
          fill_in 'Email', with: 'test@gmail.com'
          fill_in 'Password', with: '123123123123'
          fill_in 'Confirm password', with: '123123123123'

          click_button 'Sign up'
        end

        within '.alert.alert-dismissible.fade.in.alert-info' do
          expect(page).to have_content 'Welcome! You have signed up successfully.'
        end
      end
    end

    context 'with invalid credentials' do
      it 'should fail' do
        visit new_user_registration_path
        click_button 'Sign up'

        expect(page).to have_selector '.field.first_name .sign_up_error'
        expect(page).to have_selector '.field.last_name .sign_up_error'
        expect(page).to have_selector '.field.email .sign_up_error'
        expect(page).to have_selector '.field.password .sign_up_error'
        expect(page).not_to have_selector '.field.password_confirmation .sign_up_error'
      end
    end
  end
end
