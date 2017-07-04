module Pageable
  extend ActiveSupport::Concern

  included do
    belongs_to :page, counter_cache: true
    def self.for_customer(customer_id)
      joins(page: { owned_pages: { account: :customer } }).where('customers.id': customer_id)
    end
  end
end
