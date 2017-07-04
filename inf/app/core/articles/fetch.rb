module Articles
  class Fetch
    def initialize(options)
      @url = options[:url]
      @uuid = options[:uuid]
    end

    def call
      @service = ::NewsItems::Fetch.new(normalized_url)
      @service.call

      @image = image_for(@service.data)
    end

    def data
      @image.try(:persisted?) ? json_data : nil
    end

    private

    def json_data
      {
        title: title,
        description: description,
        image: {
          uuid:          @uuid,
          size:          @image.file.size,
          url:           @image.file.url,
          id:            @image.id,
          thumbnail_url: @image.file.preview.url
        }
      }
    end

    def title
      @service.data[:title]
    end

    def description
      @service.data[:description]
    end

    def image_for(data)
      return nil if data.blank? || data[:image].blank?
      ArticleImage.create(remote_file_url: data[:image])
    end

    def normalized_url
      @normalized_url ||= Addressable::URI.parse(@url).normalize.to_s rescue @url
    end
  end
end
