require 'rails_helper'

feature 'Admin hospitals' do
  describe 'Login as manager' do
    before do
      admin = create :admin
      login_as admin, scope: :admin
    end

    it 'Should display error message with wrong contact email and no manager' do
      create :hospital

      visit admin_hospitals_path
      click_link 'Login as a Manager'

      expect(page).to have_content 'You need to create manager account for this hospital'
      expect(page).to have_content 'MEDeTOURISM - Admin'
    end

    it 'Should login current hospital manager if present' do
      hospital = create :hospital, name: 'Good Hospital'
      create :manager, hospital: hospital

      visit admin_hospitals_path
      click_link 'Login as a Manager'

      expect(page).to have_content 'Back to Admin'
    end
  end
end
