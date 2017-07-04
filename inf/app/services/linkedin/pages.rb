module Linkedin
  class Pages < ::Linkedin::Service
    def index
      res = fetch_index
      data = res['values']
      return [] if data.blank?
      data.map do |page|
        uid = page['id']
        page['picture'] = picture(uid)
        page
      end
    end

    def info(uid, fields = nil)
      fields ||= %w(name logo-url).join(',')
      get "companies/#{uid}:(#{fields})"
    end

    def picture(uid)
      res = info(uid, 'logo-url')
      res['logoUrl']
    end

    def valid_token?
      fetch_index
      true
    rescue ::Linkedin::AuthException
      false
    rescue
      true
    end

    private

    def fetch_index
      get 'companies', 'is-company-admin' => true
    end
  end
end
