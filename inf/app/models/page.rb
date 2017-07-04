class Page < ApplicationRecord
  include Providerable
  include PgSearch

  has_many :posts, dependent: :destroy
  has_many :recent_posts, -> { recent }, class_name: 'Post'
  has_many :histories, as: :historyable, dependent: :destroy
  has_many :demographics, dependent: :destroy

  has_many :owned_pages, dependent: :destroy
  has_many :accounts, through: :owned_pages

  has_many :featured_pages, dependent: :destroy
  has_many :source_pages, dependent: :destroy

  enum handle_type: { handle: 0, hashtag: 1 }

  scope :ordered, -> { order(:handle) }
  scope :owned, -> { joins(:owned_pages).distinct }
  scope :page_search, ->(q) { pg_search(q) if q.present? }
  scope :not_owned, -> { left_outer_joins(:owned_pages).where(owned_pages: { id: nil }) }

  validates :provider_id, presence: true

  pg_search_scope :pg_search, against: [:title, :handle, :uid], using: { tsearch: { prefix: true } }

  def self.handle_types_collection
    [%w(@handle handle), %w(#hashtag hashtag)]
  end

  attr_accessor :checked

  def api_handle
    uid || handle
  end

  def touch_owned_pages
    owned_pages.update_all(last_updated_at: DateTime.current)
  end
end
