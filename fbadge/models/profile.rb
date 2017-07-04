class Profile < ApplicationRecord
  has_one :ticket
  has_one :registration
  belongs_to :user, optional: true
  belongs_to :event
  has_many :votes, through: :registration

  enum role: %i(visitor speaker organiser)

  validates :name, :surname, :role, presence: true

  scope :as_role, -> (role) { where(role: role) }

  def official_name
    "#{surname}, #{name}"
  end

  def full_name
    "#{name} #{surname}"
  end
end
