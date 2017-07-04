class Monitoring < ApplicationRecord
  belongs_to :domain
  has_many :histories, dependent: :destroy

  enum monitoring_type: Monitorings::Enum.types
  enum last_status: Monitorings::Enum.statuses

  scope :by_type, ->(type) { where(monitoring_type: type) }
  scope :need_check, ->(datetime) { where('checked_at <= ? OR checked_at IS NULL', datetime) }
end
