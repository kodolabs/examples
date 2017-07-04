require 'rails_helper'

feature 'Enquiry creation' do
  let(:user) { create :user }
  let(:patient) { create :patient, user: user }
  let!(:manager)         { create :manager }
  let!(:location_parent) { create :location }
  let!(:location)        { create :location, parent: location_parent }
  let!(:hospital)        { create :hospital, manager: manager, location: location }
  let!(:procedure)       { create :procedure, hospitals: [hospital], parent: create(:procedure) }

  context 'when user logged in' do
    before { login_as user, scope: :user }

    context 'when procedure should be selected' do
      before { visit hospital_path(hospital) }

      context 'when procedure not selected' do
        it 'should show error message', js: true do
          click_link 'Request a quote'
          expect(page).to have_content 'Please choose procedure to continue'
        end
      end

      context 'when procedure selected' do
        it 'should show enquiry form popup', js: true do
          select_option('procedure_id', procedure.name)
          click_link 'Request a quote'
          expect(page).to have_css '.demand-modal__procedure-name', text: procedure.name
        end
      end
    end

    context 'when procedure already selected' do
      context 'when procedure_id is correct' do
        it 'should show specified procedure', js: true do
          visit hospital_path(hospital, procedure: procedure.slug)
          expect(page).to have_css 'h3.aside-panel__title', text: procedure.name
          click_link 'Request a quote'
          expect(page).to have_css '.demand-modal__procedure-name', text: procedure.name
        end
      end

      context 'when procedure_id is not correct' do
        it 'should allow to select correct procedure', js: true do
          visit hospital_path(hospital, procedure: 'wrong-slug')
          expect(page).to have_css '.aside-panel__body-header .selectize-input'
        end
      end
    end
  end
end
