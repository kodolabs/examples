require 'rails_helper'

feature 'Facilitator patient' do
  let(:facilitator) { create :facilitator }

  before { facilitator_sign_in facilitator }

  it 'should be created by facilitator' do
    visit new_facilitator_patient_path
    within 'form.form-profile' do
      fill_in 'First name', with: 'John'
      fill_in 'Last name', with: 'Doe'

      click_button('Submit', match: :first)
    end
    within '.alert-success' do
      expect(page).to have_content 'Patient account created successfully'
    end
  end

  context 'with created patient' do
    before do
      @patient = create(:patient, facilitator: facilitator).decorate
    end

    it 'should be editable by facilitator' do
      visit edit_facilitator_patient_path @patient
      within 'form.form-profile' do
        fill_in 'Address', with: 'Address'

        click_button('Submit', match: :first)
      end
      within '.alert-info' do
        expect(page).to have_content 'Patient account updated successfully'
      end
    end

    it 'list should be displayed' do
      visit facilitator_patients_path
      expect(page).to have_content @patient.full_name
    end
  end
end
