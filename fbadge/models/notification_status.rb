class NotificationStatus < ApplicationRecord
  belongs_to :notification, counter_cache: :recipients_count
  belongs_to :registration

  after_save :count_delivered_status

  enum status: %i(pending delivered)

  def count_delivered_status
    notification.update_delivered_count if delivered?
  end
end
