class Location < ActiveRecord::Base
  DEFAULT_COUNTRY = 'AU'.freeze
  PER_PAGE = 10

  include PgSearch

  belongs_to :customer
  has_many :reviews, dependent: :destroy
  has_many :connections, dependent: :destroy
  has_many :sources, through: :connections
  has_and_belongs_to_many :users
  has_and_belongs_to_many :location_groups
  has_and_belongs_to_many :alerts
  belongs_to :manager, class_name: 'User'

  validates :name, :address, :city, :postcode, :country, :state, presence: true
  validates :flagging_rule, presence: { if: 'flagging?' }

  mount_uploader :logo, FeedbackTemplateLogo

  scope :ordered, -> { order(:name) }

  pg_search_scope :location_search,
    against: [:name, :address, :city, :postcode],
    using: {
      tsearch: { prefix: true }
    }

  def self.collection_for(user, filter_attributes)
    location_collection(user, filter_attributes).ordered.pluck(:name, :id)
  end

  def self.location_collection(user, filter_attributes)
    relation = user.available_locations
    relation = relation.joins(:connections).where('connections.source_id = :source_id', source_id: filter_attributes[:source_id]) if filter_attributes[:source_id].present?
    relation = relation.joins(:location_groups).where('location_groups.id = :group_id', group_id: filter_attributes[:group_id]) if filter_attributes[:group_id].present?
    relation.ordered
  end
end
