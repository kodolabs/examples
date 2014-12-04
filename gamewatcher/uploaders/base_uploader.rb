# encoding: utf-8

class BaseUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  def store_dir
    "#{prefix}#{model.class.to_s.underscore}/#{mounted_as}/#{hash}/#{model.id}"
  end

  def prefix
    path = []
    path << 'system' if self._storage.eql? CarrierWave::Storage::File
    path << 'test' if Rails.env.test?
    path.join('/') + '/' unless path.empty?
  end

  def hash
    model.id.to_s[-1] + '/' + Digest::MD5.hexdigest(model.id.to_s)[0,2]
  end

  def default_url
    # For Rails 3.1+ asset pipeline compatibility:
    ActionController::Base.helpers.asset_path('fallback/' + [mounted_as, version_name, 'default.png'].compact.join('_'))
  end

  def extension_white_list
    %w(jpg jpeg png)
  end

  def sharpen
    manipulate! do |img|
      img.sharpen('1x3')
      img = yield(img) if block_given?
      img
    end
  end

  def get_image_width(image_path)
    if image_path.present?
      image = MiniMagick::Image.open(image_path)
      width = image[:width]
      image.destroy!

      return width
    end

    0
  end
end
