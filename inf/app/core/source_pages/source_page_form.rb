module SourcePages
  class SourcePageForm < Pages::BaseForm
    attribute :title, String
    attribute :handle, String
    attribute :provider, Integer
    attribute :handle_type, String
    attribute :feed_id, Integer

    validates :title, :handle, :provider, :handle_type, presence: true
    validate :validate_title_uniqueness
    validate :source_presence

    private

    def validate_title_uniqueness
      return if unique_title?
      errors.add(:base, "#{handle_type.camelcase} has already been taken")
    end

    def unique_title?
      feed = Feed.find(feed_id)
      feed.pages.where(provider_id: provider).send(handle_type)
        .where('lower(handle) = ?', handle.downcase).empty?
    end

    def source_presence
      return unless provider.present? && handle.present?
      result = SourcePage::Present.new(provider, handle_type, handle).call
      errors.add(:base, "Page doesn't exist") unless result
    end
  end
end
