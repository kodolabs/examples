require 'linkedin/service'
module Linkedin
  class SavePageInfo
    def initialize(page)
      @page = page
    end

    def call
      return if @page.blank?
      return if token.blank?
      data = ::Linkedin::Pages.new(token).info(@page.uid)
      @page.attributes = attributes_for(data)
      @page.save if @page.changed?
    rescue ::Linkedin::AuthException, ::Linkedin::ApiException
      return
    end

    private

    def token
      @page.decorate.linkedin_api_token
    end

    def attributes_for(data)
      {
        logo: data['logoUrl'],
        title: data['name'],
        description: data['description']
      }
    end
  end
end
