require 'rails_helper'

feature 'Patient profile' do
  let(:user)       { create :user }
  let!(:patient)   { create :patient, user: user }
  before { user_sign_in user }

  context 'when no preop form created', :js do
    specify 'can create it' do
      visit patient_root_path(patient)
      expect(page).not_to have_content 'Permanently erase saved form'
      expect(page).to have_content 'Create form'
      # TODO: fill all the form fields and click on Submit
    end
  end

  context 'when preop form already created', :js do
    before do
      create :preop_form, patient: patient
      visit patient_root_path(patient)
    end

    specify 'can update it' do
      click_on 'Update form'
      within '#preop-modal' do
        find('[name="preop_form[data][weight]"]').set('75')
        click_on 'Submit'
      end

      click_on 'Update form'
      within '#preop-modal' do
        expect(find('[name="preop_form[data][weight]"]').value).to eq '75'
      end
    end

    # TODO: uncomment when feature available again
    # specify 'can delete it' do
    #   click_with_confirmation '.erase-form'
    #   expect(page).to have_content 'Create form'
    #   expect(page).not_to have_content 'Update form'
    # end
  end
end
