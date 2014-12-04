# encoding: utf-8

class GameUploader < BaseUploader

  version :cropbox do
    resize_to_limit 400, nil
    process quality: 80
  end

  version :medium do
    process :medium_crop
    resize_to_fill 299, 160
    process quality: 80
  end

  version :sidebar, from_version: :medium do
    resize_to_fill 85, 56
    process quality: 80
  end

  version :small, from_version: :medium do
    resize_to_fill 128, 87
    process quality: 80
  end

  version :featured, from_version: :medium, if: :featured_mods do
    resize_to_fill 243, 145
    process quality: 80
  end

  version :cover, if: :wider_1100 do
    process :cover_crop
    resize_to_fill 1100, 282
    process quality: 80
  end

  def cover_crop
    if model.cover_crop_x.present?
      manipulate! do |img|
        x = model.cover_crop_x.to_i
        y = model.cover_crop_y.to_i
        w = model.cover_crop_w.to_i
        h = model.cover_crop_h.to_i
        img.crop("#{w}x#{h}+#{x}+#{y}")
        img
      end
    end
  end

  def medium_crop
    if model.medium_crop_x.present?
      manipulate! do |img|
        x = model.medium_crop_x.to_i
        y = model.medium_crop_y.to_i
        w = model.medium_crop_w.to_i
        h = model.medium_crop_h.to_i
        img.crop("#{w}x#{h}+#{x}+#{y}")
        img
      end
    end
  end

  private

  def featured_mods(image)
    true if model.featured_mods
  end

  def wider_1100(image)
    image_path = image.respond_to?('url') ? image.url : image.path

    width = get_image_width(image_path)

    width >= 1100
  end
end
