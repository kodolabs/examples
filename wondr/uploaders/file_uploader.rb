# encoding: utf-8

class FileUploader < CarrierWave::Uploader::Base

  include CarrierWave::MimeTypes
  include CarrierWave::MiniMagick

  process :save_content_type_in_model

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{model.class.to_s.underscore}/#{hash}/#{model.id}"
  end

  def hash
    model.id.to_s[-1] + '/' + Digest::MD5.hexdigest(model.id.to_s)[0,2]
  end

  # Create different versions of your uploaded files:
  version :thumb, if: :is_image? do
    process resize_to_fill: [50, 50]
  end

  version :preview, if: :is_image? do
    process resize_to_fill: [383, 214]
  end

  version :timeline, if: :is_image? do
    process resize_to_fit: [450, nil]
  end

  version :gallery_single, if: :is_image? do
    process resize_to_fit: [1265, nil]
  end

  version :gallery_multiple, if: :is_image? do
    process resize_to_limit: [1100, nil]
  end

  def save_content_type_in_model
    model.content_type = file.content_type if file.content_type
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
     %w(jpg jpeg gif png mov mp4)
  end

  def is_image?(options)
    content_type.match /image/
  end

  def is_video?(options)
    content_type.match /video/
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  def move_to_cache
    true
  end

  def move_to_store
    true
  end


end
