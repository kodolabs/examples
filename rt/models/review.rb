class Review < ActiveRecord::Base
  PER_PAGE = 10

  STATUS_UNREAD = 0
  STATUS_READ = -2
  STATUS_RESPONDED = -1
  STATUS_INVESTIGATING = -4
  STATUSES = { _in_progress: STATUS_INVESTIGATING, _responded: STATUS_RESPONDED, _read: STATUS_READ, _unread: STATUS_UNREAD }.freeze

  enum status: STATUSES

  belongs_to :location
  belongs_to :source

  has_one :request_invitation
  has_one :customer, through: :location
  has_one :task

  has_many :comments, as: :discussable

  scope :flagged, -> { order(flag: :desc) }
  scope :ordered, -> { order(posted_at: :desc) }
  scope :of_customer, -> (customer) { joins(:location).where('locations.customer_id = ?  ', customer.id) if customer }
  scope :of_location, -> (location) { where('reviews.location_id = ?  ', location.id) if location }
  scope :of_location_group, -> (group) { where('reviews.location_id IN (?) ', group.locations.pluck(:id)) if group }
  scope :of_user_locations, -> (user) { where(location_id: user.available_locations) }
  scope :posted_in, -> (range) { where(posted_at: range) if range }
  scope :with_rating, -> { where.not(rating: nil) }
  scope :without_rating, -> { where(rating: nil) }
  scope :by_review_type, -> (review_type) { where('rating >= :from AND rating <= :to', AlertsServices::ConvertReviewType.from_type(review_type)) if review_type.present? }

  validates :posted_at, :location_id, :source_id, presence: true
  validates :content, presence: true, if: 'validate_content.present?'
  validates :rating, inclusion: { in: FeedbackServices::RecalculateRating::REVIEW_RATING_RANGE, allow_nil: true }
  validates :email, format: { with: /\A\S+@.+\.\S+\z/ }, allow_blank: true

  attr_accessor :validate_content, :without_rating, :first_name, :last_name

  include PgSearch

  pg_search_scope :task_reviews_search,
    associated_against: {
      source: [:name, :website],
      location: [:name]
    },
    against: [:title],
    using: {
      tsearch: { prefix: true }
    }

  def self.task_reviews_search(value)
    where(<<-SQL.squish, search: "%#{value.downcase}%")
      (lower(locations.name) LIKE :search) OR (lower(sources.name) LIKE :search) OR (lower(sources.website) LIKE :search) OR (lower(reviews.title) LIKE :search)
    SQL
  end

  def self.status_names
    STATUSES.map { |key, value| [I18n.t("activerecord.attributes.review.statuses.#{key}"), value] }
  end

  def self.status_names_keys
    STATUSES.map do |key, _value|
      [
        key.to_s.humanize,
        key,
        'data-content': "<span class='select-status select-status--#{key.to_s[1..-1]}'>#{I18n.t("activerecord.attributes.review.statuses.#{key}")}</span"
      ]
    end
  end
end
