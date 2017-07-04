require 'rails_helper'

describe Organisers::Register do
  let(:user)        { attributes_for :user }
  let(:invitation)  { create :organiser_invitation }
  let(:call)        { Organisers::Register.call @form }

  context 'with valid params' do
    specify 'should create user' do
      @form = UserRegistrationForm.from_params user.merge! token: invitation.token
      expect { call }.to change(User, :count).by(1)

      new_user = User.last
      expect(new_user.name).to eq user[:name]
      expect(new_user.surname).to eq user[:surname]
      expect(new_user.email).to eq user[:email]
      expect(new_user.phone).to eq user[:phone]

      expect(new_user.organiser).to be_present
    end

    specify 'should update invitation' do
      @form = UserRegistrationForm.from_params user.merge! token: invitation.token
      expect { call && invitation.reload }.to change(invitation, :accepted_at)
    end
  end

  context 'with invalid token' do
    specify 'should not create user' do
      @form = UserRegistrationForm.from_params user
      expect { call }.to change(User, :count).by(0)
    end
  end

  context 'with previously accepted invitation' do
    let(:invitation) { create :organiser_invitation, accepted_at: 1.day.ago }

    specify 'should update invitation' do
      @form = UserRegistrationForm.from_params user.merge! token: invitation.token
      expect { call }.to change(User, :count).by(0)
    end
  end
end
