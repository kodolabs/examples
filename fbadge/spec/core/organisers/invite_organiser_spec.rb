require 'rails_helper'

describe Organisers::Invite do
  let(:admin)         { create :admin }
  let(:invitee_email) { 'some@gmail.com' }
  let(:call)          { Organisers::Invite.call(admin, Organisers::OrganiserInvitationForm.new(email: invitee_email)) }

  context 'when user does not exist' do
    specify 'create new invitation' do
      expect { call }.to change(OrganiserInvitation, :count).by(1)
    end

    specify 'send notification email' do
      expect { call }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end

  context 'when user exists' do
    let!(:user) { create :user, email: invitee_email }

    specify 'do not send invitation' do
      expect { call }.to change(OrganiserInvitation, :count).by(0)
    end

    context 'and is not organiser' do
      specify 'grant organiser privilege' do
        expect { call }.to change(Organiser, :count).by(1)
        expect(user.organiser).to eq Organiser.last
      end
    end

    context 'and is already organiser' do
      let!(:organiser) { create :organiser, user: user }

      specify 'grant organiser privilege' do
        expect { call }.to change(Organiser, :count).by(0)
        expect(user.organiser).to eq Organiser.last
      end
    end
  end
end
