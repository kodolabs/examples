require 'rails_helper'

feature 'Hospital Search' do
  describe 'autocomplete', js: true, skip: true do
    it 'returns correct suggestions for procedures' do
      treatment = create :procedure, name: 'Dentistry'
      type = create :procedure, name: 'Crowns', parent: treatment
      create :procedure, name: 'Porcelain Crowns', parent: type
      other_treatment = create :procedure, name: 'Anesthetics'
      other_type = create :procedure, name: 'Anesthesia', parent: other_treatment
      create :procedure, name: 'General Anesthesia', parent: other_type
      reset_indexes
      result_path = '.home-hero__form-select--procedure .selectize-dropdown-content .search-option'

      visit root_path
      input = find('.home-hero__form-select--procedure .selectize-input input')
      input.send_keys('crowns')

      expect(page).to have_selector(result_path, count: 2)
      expect(page).to have_css("#{result_path}[data-value=\"2\"]")
      expect(page).to have_css("#{result_path}[data-value=\"3\"]")

      input.set('')
      input.send_keys('anesth')

      expect(page).to have_selector(result_path, count: 2)
      expect(page).to have_css("#{result_path}[data-value=\"5\"]")
      expect(page).to have_css("#{result_path}[data-value=\"6\"]")
    end

    it 'returns correct suggestions for locations' do
      region = create :location, name: 'South-Eastern Asia'
      country = create :location, name: 'Thailand', parent: region
      create :location, name: 'Bangkok', parent: country
      other_region = create :location, name: 'Western Europe'
      other_country = create :location, name: 'Germany', parent: other_region
      create :location, name: 'Berlin', parent: other_country
      reset_indexes
      result_path = '.home-hero__form-select--destination .selectize-dropdown-content .search-option'

      visit root_path
      input = find('.home-hero__form-select--destination .selectize-input input')
      input.send_keys('south-eastern')

      expect(page).to have_selector(result_path, count: 1)
      expect(page).to have_css("#{result_path}[data-value=\"1\"]")

      input.set('')
      input.send_keys('ger')

      expect(page).to have_selector(result_path, count: 1)
      expect(page).to have_css("#{result_path}[data-value=\"5\"]")

      input.set('')
      input.send_keys('bang')

      expect(page).to have_selector(result_path, count: 1)
      expect(page).to have_css("#{result_path}[data-value=\"3\"]")
    end

    it 'correctly submits the query to search results page' do
      create :location, name: 'South-Eastern Asia'
      treatment = create :procedure, name: 'Dentistry'
      create(:procedure, name: 'Crowns', parent: treatment)
      reset_indexes

      visit root_path
      find('.home-hero__form-select--procedure .selectize-input input').send_keys('crown')
      find('.home-hero__form-select--procedure .selectize-dropdown-content .search-option[data-value="2"]').click
      find('.home-hero__form-select--destination .selectize-input input').send_keys('asia')
      find('.home-hero__form-select--destination .selectize-dropdown-content .search-option[data-value="1"]').click
      find('.home-hero__submit-btn').trigger('click')

      expect(page).to have_content('Hospitals and clinics that perform CROWNS near SOUTH-EASTERN ASIA')
    end
  end
end
