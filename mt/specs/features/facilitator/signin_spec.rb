require 'rails_helper'

feature 'Facilitator Sign In' do
  let(:facilitator) { create :facilitator }

  context 'when js not enabled' do
    before { visit new_facilitator_session_path }

    context 'with valid credentials' do
      it 'should be valid with facilitator' do
        expect(page).to have_content 'Log in'

        within 'form.facilitator_signin' do
          fill_in 'Email', with: facilitator.email
          fill_in 'Password', with: facilitator.password

          click_button 'Log in'
        end
        within '.alert-info' do
          expect(page).to have_content 'Signed in successfully.'
        end
      end
    end

    context 'with invalid password' do
      it 'should fail' do
        within 'form.facilitator_signin' do
          fill_in 'Email', with: facilitator.email
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
