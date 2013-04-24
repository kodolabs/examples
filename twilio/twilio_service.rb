class TwilioService

  include Rails.application.routes.url_helpers

  attr_accessor :twilio

  def initialize
    self.twilio = TwilioClient.new
  end

  def purchase_number(country)
    twilio.purchase_number country, incoming_callback_url, status_callback_url
  end

  def release_number(number)
    twilio.release_number(number)
  end

  def incoming_call(params)
    if params.has_key?('To') && (phone = find_phone(params))
      greeting = phone.user.greeting
      twilio.greeting(greeting.nil? ? nil : greeting.record.url, record_callback_url, transcribe_callback_url)
    else
      twilio.say 'Wrong number'
    end
  end

  def record(params)
    phone = find_phone params
    unless phone.blank?
      user = phone.user
      user.messages.create from:          params['From'],
                           to:            params['To'],
                           callsid:       params['CallSid'],
                           recording_url: params['RecordingUrl'],
                           recording_sid: params['RecordingSid'],
                           length:        params['RecordingDuration'].to_i,
                           status:        'recorded'
    end
    hangup_call
  end

  def transcribe(params)
    message = Message.find_by_callsid params['CallSid']
    if message.present? && params['TranscriptionStatus'] == 'completed'
      message.update_attributes transcription: params['TranscriptionText'], status: 'transcribed'
      NotificationService.new.new_message(message)
    end
  end

  def hangup_call
    twilio.hangup
  end

  def phone_registered?(number)
    Phone.find_by_number(number).present?
  end

  def find_phone(params)
    Phone.find_by_number params['To']
  end

  def default_url_options
    { protocol: ENV['SSL_PROTOCOL'] }
  end
end
