module Campaigns
  class AvailablePublications < Rectify::Query
    def initialize(customer)
      @customer = customer
    end

    def query
      @customer.publications
        .where(owned_page: @customer.owned_pages.facebook)
        .where.not(
          id: @customer.campaigns.select(:publication_id), published_post_id: nil
        )
        .includes(:campaign, share: [:shareable], published_post: [:page, :images])
        .ordered.limit(3)
    end
  end
end
