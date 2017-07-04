require 'rails_helper'

feature 'User Sign In' do
  let!(:user)   { create :user }
  let(:patient) { create :patient, user: user }

  context 'when js enabled' do
    before { visit '/' }

    context 'with valid credentials' do
      it 'should be valid with patient', js: true do
        click_link 'Sign Up'
        click_link 'Log in'

        within 'form.new_user' do
          fill_in 'Email', with: user.email
          fill_in 'Password', with: user.password
          click_on 'Log in'
        end
        expect(page).to have_content 'Logout'
      end
    end

    context 'with invalid password' do
      it 'should fail', js: true do
        click_link 'Sign Up'
        click_link 'Log in'

        within 'form.new_user' do
          fill_in 'Email', with: user.email
          fill_in 'Password', with: 'abracadabra'
          click_on 'Log in'
        end
        expect(page).to have_content 'Invalid email or password.'
      end
    end
  end

  context 'when js not enabled' do
    before { visit new_user_session_path }

    context 'with valid credentials' do
      it 'should be valid with patient' do
        expect(page).to have_content 'Log in'

        within 'form.new_user' do
          fill_in 'Email', with: user.email
          fill_in 'Password', with: user.password

          click_button 'Log in'
        end
        within '.header__btn.header__btn--session' do
          expect(page).to have_content 'Logout'
        end
      end
    end

    context 'with invalid password' do
      it 'should fail' do
        within 'form.new_user' do
          fill_in 'Email', with: user.email
          fill_in 'Password', with: 'abracadabra'

          click_button 'Log in'
        end
        within '.alert-warning' do
          expect(page).to have_content 'Invalid email or password.'
        end
      end
    end
  end
end
