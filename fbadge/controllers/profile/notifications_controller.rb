class Profile::NotificationsController < Profile::OrganiserBaseController
  before_action :find_notifications

  def index
    @notification_form = Notifications::NotificationForm.new
  end

  def create
    @notification_form = Notifications::NotificationForm.from_params params
    Notifications::Create.call(@notification_form, @event, current_user) do
      on(:ok) { |event| redirect_to profile_event_notifications_path(event), notice: 'Notification was successfully sent' }
      on(:inactive_event) do |event|
        redirect_to profile_event_notifications_path(event), notice: "Can't send notification for inactive event"
      end
      on(:invalid) { render :index }
    end
  end

  private

  def find_notifications
    @notifications = @event.notifications.order(created_at: :desc)
  end
end
