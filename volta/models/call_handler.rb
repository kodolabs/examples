require 'net/http'
require 'net/https'

class CallHandlerException < StandardError; end

class CallHandler
  def self.dial(ring)
    params = {
      :destination    => ring.user.phone_number, # operator number
      :caller_id      => ring.user.phone_number, # operator number
      :remote_number  => ring.call.phone.number,
      :local_ring_id  => ring.id
    }

    settings = AppConfig['cloudvox']
    url = settings['url'] + '/dial'

    response = self::http_post(url, params, settings)

    log = ""
    log << "DIAL\n"
    log << "URL=#{url} user=#{settings['user']} pass=#{settings['password']}\n"
    log << "destination=#{params[:destination]} remote_number=#{params[:remote_number]}\n"
    log << "response code=#{response.code}\n"

    Rails.logger.debug log

    if response.nil?
      raise CallHandlerException.new("Application error")
    end

    unless response.code == '200'
      raise CallHandlerException.new("Invalid response: #{response.code} log=#{log}")
    end
  end



  def self.hangup(ring)

    # ring hangup command only if callid exists
    # otherwise we can't do anything but cancel the ring
    unless ring.callid.blank?

      params = {
        :ring_id => ring.callid
      }

      settings = AppConfig['cloudvox']
      url = settings['url'] + '/hangup'

      response = self::http_post(url, params, settings)

#      self.logger.info "HANGUP"
#      self.logger.info "URL=#{url} user=#{settings['user']} pass=#{settings['password']}"
#      self.logger.info "response code=#{response.code}"

      if response.nil?
        raise CallHandlerException.new("Application error")
      end

      unless response.code == '200'
        raise CallHandlerException.new("Invalid response: #{response.code}")
      end
    end

    ring.update_attributes({:status => 'hangup', :ended_at =>  Time.now.utc })

  end


  def self.commands(ring, params)
    commands = []

    unless ring.nil?
      ring.update_attributes(:status => 'call', :callid => params[:ring_id], :started_at => Time.now.utc)
      commands << {:name => 'Speak', :phrase => "Calling other party"}
      commands << {:name => 'Dial', :destination => ring.call.phone.number, :url => AppConfig['callback'] + '/status?command=dial'}
    else
      commands << {:name => 'Speak', :phrase => "Invalid destination number"}
    end

    commands
  end



  def self.dial_status(ring, status)
    ring.update_attributes({
      :status   => status == 'ANSWER' ? 'success' : 'error',
      :ended_at => Time.now.utc
    })
  end

private

  def self.http_post(url, data = {}, auth = {})
    return nil if url.blank?

    uri  = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)

    # Init POST request
    req = Net::HTTP::Post.new(uri.path)
    req.form_data = data
    req.basic_auth auth['user'], auth['password'] if auth['user']

    # Set HTTPS and ignore certs if necessary
    if uri.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    http.start { |h| h.request(req) }
  end

  def self.logger
    Rails.logger
  end
end
