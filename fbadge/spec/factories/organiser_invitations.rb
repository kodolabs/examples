FactoryGirl.define do
  factory :organiser_invitation do
    token         { SecureRandom.uuid }
    inviter       { create :admin }
    invitee_email { FFaker::Internet.email }
  end
end
