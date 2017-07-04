module NewsItems
  class NewsForm < Rectify::Form
    include ActionView::Helpers::SanitizeHelper

    attribute :url, String
    attribute :title
    attribute :description
    attribute :kind, Integer

    attribute :image
    attribute :image_url
    attribute :image_cache
    attribute :image_path
    attribute :remote_image_url
    attribute :favicon
    attribute :topic_ids
    attribute :source_title

    validates :title, :url, :source_title, presence: true
    validates :url, url: true
    validates :kind, presence: true

    validates :remote_image_url, url: true, if: proc { remote_image_url.present? }

    validates :image, file_size: { less_than_or_equal_to: ::NewsImageUploader::MAX_SIZE },
                      file_content_type: { allow: ::NewsImageUploader::EXTENSIONS }

    validate :validate_remote_image_url
    validate :url_uniqueness
    validate :html_presence
    validate :banned_keywords

    def model_attributes
      attrs = attributes.except(:image_url, :image_cache, :image_path, :image)
      attrs[:image] = image if image.present?
      attrs[:source_title] = source_title if source_title.present?
      attrs
    end

    def cache_image
      return if image_attribute.blank?
      n = News.new

      n.image = image if image.present?
      n.remote_image_url = remote_image_url if remote_image_url.present?
      self.image_url = n.image.url # relative path for preview
      self.image_cache = n.image_cache
      self.image_path = n.image.path # full path for remote_image_url validation
    end

    def preview_image_class
      image_attribute.presence ? '' : 'hidden'
    end

    def image_tab_class(tab)
      return tab == :url ? 'active' : '' if remote_image_url.present?
      tab == :file ? 'active' : ''
    end

    def image_extensions
      ::NewsImageUploader::EXTENSIONS.join(',')
    end

    def max_image_size
      ::NewsImageUploader::MAX_SIZE
    end

    def validate_remote_image_url
      return if remote_image_url.blank?

      validate_remote_image_extensions
      validate_remote_image_size
    end

    def html_presence
      attrs = { title: title, description: description }
      attrs.each do |attr, val|
        if contains_html?(val)
          message = 'contains html'
          errors.add(attr, :contains_html, message: message)
        end
      end
    end

    private

    def image_attribute
      image || remote_image_url
    end

    def validate_remote_image_size
      return if image_path.blank?
      size = File.size image_path
      valid = size < max_image_size
      max_size = max_image_size / (1024.0 * 1024.0).to_i
      message = "is not a valid image, max allowed size: #{max_size}MB"
      errors.add(:remote_image_url, :invalid_size, message: message) unless valid
    end

    def validate_remote_image_extensions
      return if image_path.blank?
      exts = image_extensions.gsub 'image/', ''
      ext = File.extname(image_path).remove('.')
      valid = exts.include?(ext)
      message = "is not a valid image, allowed: #{exts}"
      errors.add(:remote_image_url, :invalid_extensions, message: message) unless valid
    end

    def contains_html?(text)
      # https://github.com/rails/rails-html-sanitizer/issues/28
      # strip_tags and nokogiri escape special characters
      # so use custom regexp to check tags
      text =~ %r{(<\w+>.*<\/\w+>)+}
    end

    def banned_keywords
      return unless filtered?
      errors.add(:base, message: 'News contains banned keyword')
    end

    def filtered?
      ::NewsItems::Filter.new(self).call
    end

    def url_uniqueness
      return if unique_url?
      errors.add(:url, :taken)
    end

    def unique_url?
      if id.blank?
        News.where('lower(url) = ?', url.downcase).empty?
      else
        News.where('lower(url) = ?', url.downcase).where.not(id: id).empty?
      end
    end
  end
end
