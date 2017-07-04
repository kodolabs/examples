require 'rails_helper'

feature 'Organisers page' do
  let!(:first_user) { create(:user, name: 'Alex', surname: 'Smith') }
  let!(:first_organiser) { create(:organiser, user: first_user) }
  let!(:second_user) { create(:user, name: 'John', surname: 'Doe') }
  let!(:second_organiser) { create(:organiser, user: second_user) }
  let!(:third_organiser) { create(:user, name: 'Vladimir', surname: 'Kozlov') }

  describe 'with signed admin' do
    before do
      admin_sign_in
      visit admin_organisers_path
    end

    it 'should show in order' do
      organisers = page.all('.organiser')
      expect(organisers[0]).to have_content 'Doe, John'
      expect(organisers[1]).to have_content 'Smith, Alex'
      expect(page).not_to have_content 'Kozlov, Vladimir'
    end

    it 'should login as organiser' do
      organisers = page.all('.organiser')
      organisers[0].find('.btn').click
      expect(page).to have_content 'You successfully signed in as organiser'
      expect(page).to have_link 'Back to Admin'
    end
  end
end
