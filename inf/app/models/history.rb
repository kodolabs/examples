class History < ApplicationRecord
  belongs_to :historyable, polymorphic: true

  include Periodable

  scope :ordered, -> { order(date: :desc) }
  scope :paged, -> { where(historyable_type: 'Page') }
  scope :posted, -> { where(historyable_type: 'Post') }

  def self.for_interval(start_date, end_date = Time.current)
    where('date >= ? AND date < ?', start_date, end_date)
  end

  def self.for_customer(customer_id)
    paged.joins('INNER JOIN owned_pages ON historyable_id = owned_pages.page_id')
      .joins('INNER JOIN accounts ON owned_pages.account_id = accounts.id')
      .joins('INNER JOIN customers ON accounts.customer_id = customers.id')
      .where('customers.id': customer_id)
  end

  def self.for_page(page_id)
    posted.joins('INNER JOIN posts ON historyable_id = posts.id')
      .joins('INNER JOIN pages ON posts.page_id = pages.id')
      .where('pages.id': page_id)
  end
end
