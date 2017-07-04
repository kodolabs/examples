class Article < ApplicationRecord
  belongs_to :blog, touch: true
  has_many :article_images, dependent: :destroy
  has_many :links, dependent: :destroy
  has_many :articles_topics, dependent: :destroy
  has_many :topics, through: :articles_topics
  enum status: Articles::Enum.statuses
  enum content_type: Articles::Enum.content_types
  enum publishing_status: Articles::Enum.publishing_statuses, _prefix: :article

  scope :ordered, -> { order(published_at: :desc) }
  scope :by_blog, ->(id) { where(blog_id: id) }
  scope :need_publish, -> { where(publishing_status: [:publish, :pending]) }
  scope :need_sync, lambda {
                      need_publish
                        .where('synced_at IS NULL OR updated_at::timestamp(0) > synced_at::timestamp(0)')
                    }
  scope :search_by_title, ->(title) { where('lower(title) ILIKE ?', "%#{title.downcase}%") }
  scope :search_by_campaign, lambda { |campaign|
                               where('lower(campaigns.domain) ILIKE ?', "%#{campaign.downcase}%")
                             }
  scope :search_by_domain, ->(domain) { where('lower(domains.name) ILIKE ?', "%#{domain.downcase}%") }
  scope :search_by_topics, ->(topics) { where('topics.keyword IN (?)', topics) }
  scope :no_links, -> { where(links: { id: nil }) }
  scope :has_links, -> { where.not(links: { id: nil }) }

  validates :title, :body, :blog, :published_at, presence: true

  def self.statuses_collection
    publishing_statuses.keys.map do |status|
      [status, status&.titleize]
    end
  end

  def not_synced?
    return false if [:publish, :pending].exclude?(publishing_status.to_sym)
    updated_at.to_i > synced_at.to_i
  end
end
