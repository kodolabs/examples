class Importer
  def self.push(msg)
    data = JSON.parse msg
    connection = Connection.find_by(watch_id: data['watch_id'])

    return false if connection.nil?
    return false if connection.location.nil?
    return false if connection.location.customer.nil? || !connection.location.customer.active?

    review_attributes = attributes(data).merge(source_id: connection.source_id)
    review_attributes['title'] = nil if review_attributes['title'].blank?
    review_attributes['rating'] = nil unless review_attributes['rating'].to_i.positive?

    new_review = connection.location.reviews.new review_attributes

    unless new_review.save
      Rollbar.error "Review Invalid. Errors #{new_review.errors.full_messages.to_sentence}. Attributes: #{new_review.attributes}"
      return false
    end

    ReviewServices::CheckFlaggingRule.new(new_review).call
    GenerateShortLinkWorker.perform_async(new_review.id) if new_review.origin_url.present?

    GeneratePushByReviewWorker.perform_async(new_review.id, connection.location.customer_id) if connection.processed?

    new_review.id
  rescue JSON::ParserError => e
    # TODO: better error handling
    Rails.logger.error "ERROR: Invalid JSON message: #{e}"
    false
  rescue ActiveRecord::RecordInvalid => e
    Rollbar.error e
    false
  rescue => e
    Rollbar.error e
    false
  end

  def self.attributes(data)
    data.slice('author', 'title', 'content', 'rating', 'posted_at', 'origin_url')
  end
end
