class OrganiserInvitation < ApplicationRecord
  belongs_to :inviter, class_name: 'Admin'

  validates :inviter, :token, presence: true
  validates :token, uniqueness: true

  before_validation :generate_token

  scope :pending, -> { where(accepted_at: nil) }
  scope :ordered, -> { order(created_at: :desc) }

  def generate_token
    self.token = SecureRandom.uuid
  end
end
