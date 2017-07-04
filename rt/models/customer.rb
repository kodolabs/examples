class Customer < ActiveRecord::Base
  STATUS_ACTIVE = 0
  STATUS_SUSPENDED = 1
  STATUS_CANCELLED = 2

  enum status: { active: STATUS_ACTIVE, suspended: STATUS_SUSPENDED, cancelled: STATUS_CANCELLED }

  has_one  :subscription, inverse_of: :customer
  has_one  :plan, through: :subscription
  has_one  :credit_card

  has_one  :primary_user, -> { where(users: { primary: true }) }, class_name: 'User', foreign_key: :customer_id, inverse_of: :customer

  belongs_to :business_type
  belongs_to :created_by, class_name: 'Admin'
  belongs_to :selected_plan, class_name: 'Plan'

  has_many :payments, through: :subscription
  has_many :users, inverse_of: :customer, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :location_groups, dependent: :destroy
  has_many :reviews, through: :locations
  has_many :connections, through: :locations
  has_many :requests
  has_many :email_templates
  has_many :feedback_templates
  has_many :tasks
  has_many :alerts
  has_many :access_tokens, dependent: :destroy

  attr_accessor :terms, :validate_selected_plan, :primary_user_id, :lead_id

  accepts_nested_attributes_for :users
  accepts_nested_attributes_for :subscription

  validates :selected_plan_id, presence: true, if: 'validate_selected_plan.present?'
  validates :business_type_id, presence: true
  validates :business_name, :business_phone, presence: true

  before_create :set_up_notify_date, if: 'notified_at.blank?'
  before_save :set_terms_accepted_at, if: 'terms.present?'

  scope :ordered, -> { order(:created_at) }
  scope :of_user, -> (user) { where(created_by: user) }

  delegate :last_four, to: :credit_card, allow_nil: true

  def safe_plan
    plan || selected_plan
  end

  def users_collection
    users.order(first_name: :asc, last_name: :asc).pluck(:id, :first_name, :last_name).map do |info|
      ["#{info[1]} #{info[2]}", info[0]]
    end
  end

  def locations_collection
    locations.ordered.pluck(:name, :id)
  end

  def task_users_collection
    users.decorate.map { |u| [u.safe_name, u.id] }
  end

  def sources
    subscription.sources.visible.active
  end

  def can_change_to?(other_plan)
    locations.count <= other_plan.locations_included || other_plan.extra_locations_allowed
  end

  def primary_email
    primary_user.email
  end

  def primary_locale
    primary_user.locale
  end

  def payment_info?
    braintree_card_token.present?
  end

  def available_reviews_for(user)
    Review.where(location_id: user.available_locations)
  end

  private

  def set_up_notify_date
    self.notified_at = DateTime.now
  end

  def set_terms_accepted_at
    self.terms_accepted_at = DateTime.now
  end
end
