module Receptionists
  class ReceptionistForm < Rectify::Form
    attribute :name, String
    attribute :email, String

    validates :name, :email, presence: true
    validates :email, format: { with: /\A\S+@.+\.\S+\z/ }
  end
end
