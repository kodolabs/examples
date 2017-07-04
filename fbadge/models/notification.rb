class Notification < ApplicationRecord
  belongs_to :event
  belongs_to :sender, class_name: 'Profile'
  has_many :notification_statuses, dependent: :destroy

  validates :title, :text, presence: true

  def update_delivered_count
    update_attributes(delivered_count: notification_statuses.delivered.count)
  end
end
