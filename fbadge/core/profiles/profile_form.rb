module Profiles
  class ProfileForm < Rectify::Form
    attribute :name, String
    attribute :surname, String
    attribute :phone, String
    attribute :company, String
    attribute :job_title, String

    validates :name, :surname, presence: true
  end
end
