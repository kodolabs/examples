require 'rails_helper'

feature 'Organisers invitations' do
  before { admin_sign_in }

  let(:new_email) { 'some@gmail.com' }

  context 'invite' do
    before { visit admin_organisers_path }

    specify 'new organiser' do
      find('#new').click

      fill_in 'Email', with: 'some@gmail.com'
      click_button 'Submit'

      expect(page).to have_content "Successfully invited \"#{new_email}\""
    end

    specify 'existing user' do
      create :user, email: new_email

      find('#new').click

      fill_in 'Email', with: new_email
      click_button 'Submit'

      expect(page).to have_content "User \"#{new_email}\" invited as organiser"
    end

    specify 'existing organiser' do
      create :user, :organiser, email: new_email

      find('#new').click

      fill_in 'Email', with: new_email
      click_button 'Submit'

      expect(page).to have_content "User \"#{new_email}\" is already an organiser"
    end
  end

  context 'index' do
    let!(:first_invitation) { create :organiser_invitation }
    let!(:second_invitation) { create :organiser_invitation }
    let!(:accepted_invitation) { create :organiser_invitation, accepted_at: 1.day.ago }

    before { visit admin_organiser_invitations_path }

    it 'should not show accepted invitations' do
      expect(page).to_not have_content accepted_invitation.invitee_email
    end

    it 'should show in order' do
      invitations = page.all('.organiser-invitation')
      expect(invitations[0]).to have_content second_invitation.invitee_email
      expect(invitations[1]).to have_content first_invitation.invitee_email
    end

    it 'should deleted invitation' do
      invitations = page.all('.organiser-invitation')
      invitations[0].find('a').click

      expect(page).to have_content first_invitation.invitee_email
      expect(page).not_to have_content second_invitation.invitee_email
      expect(page).to have_content 'Organiser invitation succesfully deleted'
    end
  end
end
