class Agenda < ApplicationRecord
  belongs_to :event

  validates :date, :begins_at, :ends_at, :title, presence: true
  validate :future_date

  scope :ordered, -> { order(:date, :begins_at) }

  def future_date
    return if date.blank?
    errors.add(:date, "can't be in the past") if date.past?
  end
end
