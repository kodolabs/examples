# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  def store_dir
    "#{model.class.to_s.underscore}/#{hash}/#{model.id}"
  end

  def hash
    model.id.to_s[-1] + '/' + Digest::MD5.hexdigest(model.id.to_s)[0,2]
  end

  def default_url
    ActionController::Base.helpers.asset_path("fallback/" + [mounted_as, version_name, "default.png"].compact.join('_'))
  end

  version :thumb do
    process :resize_to_fill => [100, 100]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
