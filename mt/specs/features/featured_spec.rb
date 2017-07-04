require 'rails_helper'

feature 'Quality Healthcare Page' do
  it 'navigate-able from homepage' do
    visit '/'
    expect(page).to have_link('Quality Healthcare', href: quality_healthcare_path)
  end

  context 'with featured hospitals' do
    before do
      _hospital_with_plus_partner = create :hospital, name: "London's main hospital", description: 'Best dental hospital', featured: true, plus_partner: true
      _hospital_without_plus_partner = create :hospital, name: "Manchester's main hospital", description: 'Best dental hospital', featured: true, plus_partner: false
      _hospital_not_featured = create :hospital, name: "Liverpool's main hospital", description: 'Best dental hospital', featured: false, plus_partner: false
      visit quality_healthcare_path
    end

    it 'should show in order' do
      featured_hospitals = page.all('.featured-hospital')
      expect(featured_hospitals[0]).to have_content "London's main hospital"
      expect(featured_hospitals[1]).to have_content "Manchester's main hospital"
    end

    it 'should show featured hospitals only' do
      expect(page).not_to have_content "Liverpool's main hospital"
    end
  end

  context 'without featured hospitals' do
    it "should show 'not found' message" do
      visit quality_healthcare_path
      expect(page).to have_content 'Featured hospitals not found'
    end
  end
end
