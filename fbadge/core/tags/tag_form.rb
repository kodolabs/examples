module Tags
  class TagForm < Rectify::Form
    attribute :keyword, String

    validates :keyword, presence: true
    validate :validate_keyword_uniqueness

    def model_attributes
      attributes.merge(keyword: keyword.downcase)
    end

    private

    def validate_keyword_uniqueness
      return if unique_keyword?
      errors.add(:keyword, :taken)
    end

    def unique_keyword?
      Tag.where('lower(keyword) = ?', keyword.downcase).empty?
    end
  end
end
