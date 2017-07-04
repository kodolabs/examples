module Campaigns
  class BoostedPublications < Rectify::Query
    def initialize(customer)
      @customer = customer
    end

    def query
      @customer.publications
        .where(id: @customer.campaigns.select(:publication_id))
        .where.not(published_post_id: nil)
        .includes(:campaign, share: [:shareable], published_post: [:page, :images])
        .ordered
    end
  end
end
