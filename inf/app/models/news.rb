class News < ApplicationRecord
  include PgSearch
  include Kindable
  has_many :resolved_items, as: :decideable, dependent: :destroy
  has_many :news_topics, dependent: :destroy
  has_many :topics, through: :news_topics
  has_many :shares, dependent: :destroy, as: :shareable
  has_many :publications, through: :shares
  belongs_to :rss_domain
  mount_uploader :image, NewsImageUploader

  scope :ordered, -> { order(created_at: :desc) }
  scope :accepted, -> { all }

  validates :url, uniqueness: true, presence: true

  def resolved?(customer)
    resolved_items.where(customer: customer).any?
  end

  pg_search_scope :pg_search,
    using: {
      tsearch: { prefix: true, dictionary: 'english' }
    },
    against: { title: 'A', url: 'B', description: 'C' }

  scope :detailed_search, ->(q) { pg_search(q) if q.present? }

  def self.search(q)
    return self if q.blank?
    where('title LIKE :q OR description LIKE :q OR url LIKE :q', q: "%#{q.strip}%")
  end

  def self.without_shares_for(customer)
    left_outer_joins(:shares).where('shares.shareable_id IS NULL OR shares.customer_id != ?', customer.id)
  end
end
