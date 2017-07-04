require 'rails_helper'

feature 'Featured Treatments Page' do
  let!(:procedure) { create(:procedure) }
  let!(:treatment) { create(:featured_treatment, procedure: procedure) }
  let!(:hospital) { create(:hospital, name: "New-York's hospital") }

  context 'with content of treatment' do
    before do
      treatment.featured_treatments_hospitals << create(:featured_treatments_hospital, hospital: hospital)
      visit featured_treatment_path(treatment)
    end

    it 'should show sections in order' do
      sections = page.all('.procedures-faq__title')

      expect(sections.first).to have_content 'section 1'
      expect(sections.last).to have_content 'section 2'
    end

    it 'should show recommended hospitals' do
      expect(page).to have_content "New-York's hospital"
    end
  end
end
