class Event < ApplicationRecord
  before_validation :generate_token, on: :create

  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'
  has_many :locations, dependent: :destroy
  has_many :profiles, dependent: :destroy
  has_many :ticket_classes, dependent: :destroy
  has_many :tickets, through: :ticket_classes
  has_many :users, through: :profiles
  has_many :receptionists, dependent: :destroy
  has_many :registrations, dependent: :destroy
  has_many :polls, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :event_tags, dependent: :destroy
  has_many :tags, through: :event_tags
  has_many :agendas, -> { order(:date, :begins_at) }, dependent: :destroy

  accepts_nested_attributes_for :agendas, allow_destroy: true

  validates :name, :begins_on, :ends_on, :token, :status, presence: true
  validates :token, uniqueness: true
  validate :current_future_date?, on: :create
  validate :after_begins_on?

  enum status: %i(pending active closed)

  serialize :eventbrite_response, JSON
  serialize :sync_error, JSON

  mount_uploader :logo, EventUploader

  scope :ordered, -> { order(begins_on: :desc) }

  def creator_name
    return '[none]' if creator.blank?
    "#{creator.surname}, #{creator.name}"
  end

  def creator_email
    return '' if creator.blank?
    creator.email
  end

  def eventbrite_url
    "https://www.eventbrite.com/edit?eid=#{eventbrite_id}"
  end

  def generate_token
    self.token = SecureRandom.uuid
  end

  def current_future_date?
    return unless begins_on.present?
    errors.add(:begins_on, I18n.t('errors.events.begins_on_past')) if begins_on < DateTime.now.to_date
  end

  def after_begins_on?
    return unless begins_on.present? && ends_on.present?
    errors.add(:ends_on, I18n.t('errors.events.ends_on_early')) if ends_on < begins_on
  end
end
