module Articles
  class Validator < ActiveModel::Validator
    include ::Schedule::BaseValidator

    TWIITER_MAX_CONTENT_SIZE = 140

    # In future this value must be fetched from api daily
    # https://dev.twitter.com/basics/tco
    TWITTER_MAX_LINK_SIZE = 25

    MAX_IMAGE_COUNT = 1

    def validate(record)
      validate_targets_presence(record)
      validate_content_presence(record)
      validate_future_date_time(record)
      validate_images(record)
    end

    private

    def validate_content_presence(record)
      return if record.content.present?
      record.errors.add(:content, "Message can't be blank")
    end

    def validate_images(record)
      return if record.image_ids_str.blank?
      return unless record.image_ids_str.try(:split, ',').try(:count) > MAX_IMAGE_COUNT
      record.errors.add(:images, 'Too many images')
    end
  end
end
