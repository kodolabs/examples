class GalleryDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def upload_image_tag(upload, version = 'gallery_multiple', options = {})
    h.image_tag upload.file.versions[version.to_sym], {alt: upload.description || object.name}.merge(options)
  end

  def timeline_figure
    upload_image_tag(object.uploads.first, 'timeline', class: 'lazy')
  end

  def is_single?
    object.uploads.count == 1
  end

  def layout_class
    is_single? ? 'gallery_single' : 'gallery_multiple'
  end

  def humanize_posted_at
    object.created_at.strftime("%B %d, %Y")
  end

  def post_date
    object.created_at.strftime('%Y:%m:%d')
  end
end
