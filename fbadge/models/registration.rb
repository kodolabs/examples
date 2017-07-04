class Registration < ApplicationRecord
  belongs_to :profile
  belongs_to :badge
  belongs_to :ticket
  belongs_to :event

  has_many :notification_statuses
  has_many :votes

  validates :profile, :ticket, :event, presence: true
  validates :badge, presence: :true, unless: :is_canceled?

  has_many :votes

  scope :ordered, -> { order(created_at: :desc) }
  scope :active,  -> { where(active: :true) }

  delegate :ticket_class_name, to: :ticket
  delegate :official_name, to: :profile
end
