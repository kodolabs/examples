class User < ActiveRecord::Base
  include AvailableLocations
  include PgSearch
  attr_accessor :terms

  PER_PAGE = 10

  belongs_to :customer, inverse_of: :users
  has_one :lead
  has_many :alerts, foreign_key: 'recipient_id'
  has_many :comments
  has_and_belongs_to_many :locations
  has_many :assigned_tasks, class_name: 'Task', foreign_key: :assigned_to_id, dependent: :nullify
  has_many :created_tasks, class_name: 'Task', foreign_key: :created_by_id, dependent: :destroy
  has_many :access_tokens, dependent: :destroy

  validates :terms, acceptance: true

  validates :first_name, :last_name, :phone, presence: true
  devise :database_authenticatable, :registerable, :validatable, :confirmable, :recoverable

  attr_accessor :skip_password_validation, :skip_change_password_mail

  accepts_nested_attributes_for :customer, :locations

  mount_uploader :avatar, AvatarUploader

  enum role: { account_admin: 0, location_manager: 1, general_access_user: 2, email_notification_user: 3, view_only_user: 4 }
  scope :ordered, -> { order(first_name: :asc, last_name: :asc) }

  pg_search_scope :user_search,
    against: [:first_name, :last_name, :email, :phone],
    using: {
      tsearch: { prefix: true }
    }

  def active_for_authentication?
    super && UserPolicy.new(self).can_login?
  end

  def inactive_message
    case customer.status
    when 'suspended'
      I18n.t('customer.messages.customer.suspended')
    when 'cancelled'
      I18n.t('customer.messages.customer.cancelled')
    else
      return I18n.t('customer.messages.user.email_notification_user') if email_notification_user?
      super
    end
  end

  def self.assigned_for(task)
    available_users = with_review(task.review)
    task_user = task.assigned_to
    available_users << task_user if task_user && !available_users.include?(task_user)
    available_users
  end

  def self.with_review(review)
    with_location(review.location)
  end

  def self.with_location(location)
    joins('LEFT OUTER JOIN locations_users ON locations_users.user_id = users.id')
      .where('locations_users IS NULL OR locations_users.location_id = ?', location.id)
  end

  def send_password_change_notification
    return true if skip_change_password_mail
    super
  end

  protected

  def password_required?
    return false if skip_password_validation
    super
  end

  def email_required?
    true
  end

  def confirmation_required?
    false
  end
end
