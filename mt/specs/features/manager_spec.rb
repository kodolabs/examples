require 'rails_helper'

feature 'Manager' do
  let!(:patient)         { create :patient }
  let!(:manager)         { create :manager }
  let!(:location_parent) { create :location }
  let!(:location)        { create :location, parent: location_parent }
  let!(:hospital)        { create :hospital, id: 48, manager: manager, location: location }
  let!(:procedure)       { create :procedure, id: 4, hospitals: [hospital] }
  let!(:demand)          { create :demand, patient: patient, procedures: [procedure] }
  let!(:enquiry)         { create :enquiry, :pending, demand: demand, hospital: hospital }

  specify 'can login' do
    visit new_manager_session_path
    fill_in 'Email', with: manager.email
    fill_in 'Password', with: manager.password
    click_button 'Log in'
    expect(page).to have_content 'Logout'
  end

  describe 'logged in' do
    before do
      login_as manager, scope: :manager
    end

    # specify 'can see pending enquiry in dashboard' do
    #   visit manager_requests_path
    #   expect(page).to have_content 'You have pending quote requests. Please respond.'
    #   expect(page).to have_css '.hospital-proposal.hospital-proposal--pending'
    # end
  end
end
