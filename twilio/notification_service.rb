class NotificationService

  include Rails.application.routes.url_helpers

  attr_accessor :user, :message

  def new_message(message)
    self.user, self.message = message.user, message.decorate
    send_email_notification if user.notify_by_email?
    send_sms_notification if user.notify_by_sms?
  end

  def send_email_notification
    UserMailer.notification(user, message).deliver
  end

  def send_sms_notification
    require 'iron_worker_ng'
    client = IronWorkerNG::Client.new token: ENV['IRON_WORKER_TOKEN'], project_id: ENV['IRON_WORKER_PROJECT']
    client.tasks.create 'sms', {
      sid:    ENV['TWILIO_ACCOUNT_SID'],
      token:  ENV['TWILIO_AUTH_TOKEN'],
      from:   AppConfig['sms_outgoing_number'],
      to:     user.phone,
      body:   sms_message_body
    }
  end

  def sms_message_body
    "New message from #{message.from}, left at #{message.created_at} (#{message.length}). Listen #{short_url}"
  end

  def short_url
    bitly = Bitly.new(ENV['BITLY_USERNAME'], ENV['BITLY_API_KEY'])
    bitly.shorten(message_url(message)).short_url
  end
end