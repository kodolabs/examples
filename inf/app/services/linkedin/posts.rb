module Linkedin
  class Posts < Linkedin::Service
    MAX_LENGTH = 700

    def create(uid, options)
      url = options[:url]
      title = options[:title]
      description = options[:description]
      image_url = options[:image_url]
      endpoint = "companies/#{uid}/shares"

      media_fields = [url, title, description, image_url].compact
      api_params = {
        comment: options[:text]&.truncate(MAX_LENGTH),
        visibility: { code: :anyone }
      }

      api_params = media_for(api_params, options) if media_fields.present?
      post(endpoint, api_params)
    rescue RestClient::ExceptionWithResponse => e
      code = e.response.code
      case code
      when 400
        raise ::Linkedin::ApiException
      when 401
        raise ::Linkedin::AuthException
      end
    end

    def index(uid)
      get "companies/#{uid}/updates", 'event-type' => 'status-update'
    end

    private

    def media_for(api_params, options)
      only_image = options.keys.sort == %i(image_url text)
      content = only_image ? default_media_options_for(options) : media_options_for(options)
      content['submitted-image-url'] = options[:image_url]

      api_params[:content] = content
      api_params
    end

    def default_media_options_for(_options)
      {
        'submitted-url' => "https://#{host_name}",
        'description' => '',
        'title' => 'Influenza AI'
      }
    end

    def media_options_for(options)
      {
        'submitted-url' => options[:url],
        'description' => options[:description],
        'title' => options[:title]
      }
    end

    def host_name
      return ENV['HOST_NAME'] if Rails.env != 'development'
      ENV['LINKEDIN_HOST_NAME'] || ENV['HOST_NAME']
    end
  end
end
