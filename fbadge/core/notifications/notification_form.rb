module Notifications
  class NotificationForm < Rectify::Form
    attribute :title, String
    attribute :text, String

    validates :title, :text, presence: true
  end
end
