require 'rails_helper'

feature 'Hospitals' do
  let!(:locations) { create_locations_ancestry('Western Europe', 'Germany', 'Berlin') }
  let!(:hospital) { create :hospital, location: locations.last, description: 'Awesome place' }
  let!(:patient) { create(:patient) }
  let!(:first_review) { create(:review, patient: patient, hospital: hospital, quality_description: 'best') }
  let!(:second_review) { create(:review, patient: patient, hospital: hospital, quality_description: 'worst') }

  before { visit hospital_path(hospital) }

  describe 'show' do
    it 'should display content' do
      breadcrumbs = find('.breadcrumbs')

      expect(breadcrumbs).to have_content 'Berlin'
      expect(breadcrumbs).to have_content 'Germany'
      expect(breadcrumbs).to have_content hospital.name
      expect(page).to have_content 'Awesome place'
    end

    describe 'with rating' do
      it 'should show average rating' do
        within '.hospital__aux-info-item--rating' do
          expect(page).to have_content '50'
          expect(page).to have_content 'Rating'
        end
      end

      it 'should show latest reviews at the top' do
        reviews = page.all('.review')
        expect(reviews.first).to have_content second_review.quality_description
        expect(reviews.last).to have_content first_review.quality_description
      end
    end
  end
end
