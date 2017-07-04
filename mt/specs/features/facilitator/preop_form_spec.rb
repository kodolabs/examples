require 'rails_helper'

feature 'Facilitator' do
  let(:facilitator)   { create :facilitator }
  let!(:patient) { create :patient, facilitator: facilitator }
  before { facilitator_sign_in facilitator }

  context 'when no preop form created', :js do
    specify 'can create it' do
      visit edit_facilitator_patient_path(patient)
      expect(page).to have_content 'Create form'
    end
  end

  context 'when preop form already created', :js do
    before do
      create :preop_form, patient: patient
      visit edit_facilitator_patient_path(patient)
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
