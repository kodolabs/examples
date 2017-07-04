require 'rails_helper'

feature 'Featured Treatments Index Page' do
  let!(:procedure_first) { create(:procedure) }
  let!(:treatment_first) { create(:featured_treatment, procedure: procedure_first) }

  let!(:procedure_second) { create(:procedure) }
  let!(:treatment_second) do
    create(
      :featured_treatment,
      procedure: procedure_second,
      slug: 'dental-bridge',
      title: 'dental bridge',
      header: 'Dental Bridge'
    )
  end

  before { visit featured_treatments_path }

  context 'with featured treatments list' do
    it 'should show in order' do
      featured_treatments = page.all('.featured-treatment__info-block')

      expect(featured_treatments.first).to have_link('Find out more', href: featured_treatment_path(treatment_first))
      expect(featured_treatments.last).to have_link('Find out more', href: featured_treatment_path(treatment_second))
    end
  end
end
