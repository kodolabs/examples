class TwilioClient

  TWILIO_TEST_NUMBER = '+15005550006'

  attr_accessor :client

  def initialize(sid = nil, token = nil)
    sid     ||= ENV['TWILIO_ACCOUNT_SID']
    token   ||= ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new sid, token
  end

  def purchase_number(country, incoming_callback, status_callback)
    number = find_available_number country
    @client.account.incoming_phone_numbers.create phone_number: number,
                                                 voice_url: incoming_callback,
                                                 status_callback: status_callback
  end

  def find_available_number(country)
    numbers = @client.account.available_phone_numbers.get(country).local.list
    raise "No available phone numbers for #{country}" if numbers.empty?
    number = numbers.first.phone_number
  end

  def release_number(sid)
    number = @client.account.incoming_phone_numbers.get sid
    number.delete
  end

  def say(message)
    Twilio::TwiML::Response.new do |r|
      r.Say message, voice: 'woman'
    end.text
  end

  def hangup
    response = Twilio::TwiML::Response.new do |r|
      r.Hangup
    end.text
  end

  def greeting(record_url, record_callback, transcribe_callback)
    response = Twilio::TwiML::Response.new do |r|
      if record_url.present?
        r.Play record_url
      else
        r.Say "Please leave a message after the beep", voice: 'woman'
      end

      r.Record action: record_callback, transcribeCallback: transcribe_callback, maxLength: 120
    end.text
  end

  def delete_recording(recording_sid)
    recording = @client.account.recordings.get(recording_sid)
    recording.delete
  rescue
    nil
  end

  def remove_all_recordings
    @client.account.recordings.list.each do |recording|
      recording.delete
    end
  end

  def send_sms(from, to, message)
    @client.account.sms.messages.create body: message,
                                       to: to,
                                       from: from
  end
end