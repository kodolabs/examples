module Linkedin
  class ApiException < StandardError; end
  class AuthException < StandardError; end
  class ConnectionRefusedException < StandardError; end
  class ParseException < StandardError; end
  class WrongPageException < StandardError; end

  class Service
    HOST_URL = 'https://api.linkedin.com/v1/'.freeze

    def initialize(token)
      @token = token
    end

    def get(path, params = {})
      options = { params: params.merge(format: 'json') }.merge(headers)
      url = "#{HOST_URL}#{path}"
      res = RestClient.get(url, options)
      JSON.parse(res.body)

    rescue RestClient::ExceptionWithResponse => e
      raise_exception_by_code(e.response.code)
    rescue Errno::ECONNRESET
      raise ::Linkedin::ConnectionRefusedException
    end

    def post(path, params = {})
      body = params.to_json

      url = "#{HOST_URL}#{path}"
      res = RestClient.post(url, body, headers)
      JSON.parse(res.body)
    end

    private

    def raise_exception_by_code(code)
      case code
      when 400
        raise ::Linkedin::ApiException
      when 401
        raise ::Linkedin::AuthException
      end
    end

    def headers
      {
        Connection: 'Keep-Alive',
        Authorization: "Bearer #{@token}",
        'x-li-format' => 'json',
        content_type: 'json'
      }
    end
  end
end
