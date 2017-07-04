class Connection < ActiveRecord::Base
  STATUS_CHECK_TIMEOUT = 24.hours.freeze
  ANALYSIS_TIMEOUT = 20.minutes.freeze

  enum status: [:pending, :processed]

  scope :ordered, -> { joins(:source).order('sources.name') }
  belongs_to :location
  belongs_to :source

  validates :location_id, :source_id, presence: true
  validates :reviews_url, presence: true, url: true, source_url: { if: 'reviews_url.present?' }
  validates :source_id, uniqueness: { scope: :location_id }

  delegate :name, to: :source, prefix: true
  delegate :name, to: :location, prefix: true

  after_commit :create_watch, on: [:create, :update], if: proc { |record| record.watch_id.blank? }
  after_update :delete_watch, if: :empty_watch_id?
  before_destroy :delete_watch

  private

  def empty_watch_id?
    watch_id_was.present? && watch_id_changed? && watch_id.blank?
  end

  def create_watch
    Harvester.watch(self)
  end

  def delete_watch
    Harvester.unwatch(self)
  end
end
