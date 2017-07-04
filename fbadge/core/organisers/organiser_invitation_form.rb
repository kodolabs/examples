module Organisers
  class OrganiserInvitationForm < Rectify::Form
    attribute :email, String
    validates :email, presence: true
  end
end
