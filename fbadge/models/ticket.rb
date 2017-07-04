class Ticket < ApplicationRecord
  has_one :registration, dependent: :destroy
  belongs_to :ticket_class
  belongs_to :profile
  belongs_to :buyer, class_name: 'User'

  validates :ticket_class, presence: true

  delegate :name, to: :ticket_class, prefix: true

  scope :ordered, -> { order(created_at: :desc) }

  def price
    return 'FREE' unless ticket_class.cost.present? || ticket_class.cost == 0
    ticket_class.cost
  end

  def job_company
    "#{profile.try(:job_title)}" \
      " @ #{profile.company}" if profile.present? && profile.company.present?
  end
end
