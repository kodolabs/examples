class Post < ApplicationRecord
  include Pageable

  has_many :resolved_items, as: :decideable, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :videos, dependent: :destroy
  has_many :shares, as: :shareable
  has_many :publications, dependent: :destroy, foreign_key: :published_post_id
  has_many :histories, as: :historyable, dependent: :destroy

  scope :recent, -> { order(posted_at: :desc) }
  scope :most_shared, -> { order(shares_count: :desc) }
  scope :most_liked, -> { order(likes_count: :desc) }
  scope :per_month, -> { where('posted_at >= ?', Time.zone.today - 1.month) }
  scope :facebook, -> { by_provider('facebook') }
  scope :twitter, -> { by_provider('twitter') }
  scope :linkedin, -> { by_provider('linkedin') }

  serialize :attrs, JSON
  validates :uid, uniqueness: { scope: :page_id }

  delegate :provider, to: :page
  delegate :hashtag?, to: :page
  delegate :twitter?, to: :provider
  delegate :facebook?, to: :provider

  paginates_per 24

  def self.recent_streams
    includes(page: [:source_pages])
      .order('source_pages.created_at DESC, posts.posted_at DESC')
  end

  def self.by_provider(name)
    joins(:page).where('pages.provider_id = ?', Provider.send(name).id)
  end

  def self.without_authors(authors)
    where.not(author: authors)
  end

  def resolved?(customer)
    resolved_items.where(customer: customer).any?
  end
end
