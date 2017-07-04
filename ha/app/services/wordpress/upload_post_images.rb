class Wordpress::UploadPostImages
  include Ftp::Wrapper
  include Interactor
  attr_accessor :host

  def initialize(context = {})
    @article = context.article
    @host = context.article.blog.host
    @domain = context.article.blog.host.domain.decorate
    super
  end

  def call
    update_last_error

    raise I18n.t('notifications.invalid_ftp_connect') unless access_to_ftp?
    connect_to_ftp

    ftp.mkdir(wp_upload_folder) unless folder_exists?(wp_upload_folder)

    upload
    disconnect_from_ftp
  rescue => e
    update_last_error("Upload images: #{e.message}")
    disconnect_from_ftp
    context.fail!
  end

  private

  def upload
    @article.article_images.each do |image|
      path = image_path(image)
      next if path.blank? || skip_upload?(image)
      upload_to_server(image, path)
      update_original_path(image, path)
    end
  end

  def image_path(image)
    return image.original_path&.split('wp-content/uploads/')&.second if image.imported
    "#{image.created_at.strftime('%Y/%m')}/#{image.file.filename}"
  end

  def skip_upload?(image)
    return false if image.original_path.blank?
    image.original_path.index(@domain.name).present?
  end

  def upload_to_server(image, path)
    items = path.split('/')
    filename = items.pop

    file_path = wp_upload_folder
    items.map do |folder|
      file_path = "#{file_path}/#{folder}"
      next if folder_exists?(file_path)
      ftp.mkdir(file_path)
    end

    file_path = "#{file_path}/#{filename}"
    ftp.delete(file_path) if file_exists?(file_path)
    ftp.putbinaryfile(open_image(image), file_path)
  end

  def wp_upload_folder
    "#{host.site_folder}/wp-content/uploads"
  end

  def open_image(image)
    stream = open(image_full_path(image), 'rb')
    return stream if stream.respond_to?(:path)

    Tempfile.new.tap do |file|
      file.binmode
      IO.copy_stream(stream, file)
      stream.close
      file.rewind
    end
  end

  def image_full_path(image)
    image.file.url
  end

  def update_original_path(image, path)
    image.update_column(
      :original_path,
      [@domain.domain_url, 'wp-content/uploads', path].join('/')
    )
  end

  def update_last_error(message = nil)
    @article.update(last_error: message)
    @host.update(last_error: message)
  end
end
