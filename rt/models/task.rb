class Task < ActiveRecord::Base
  include PgSearch

  enum task_type: [:general, :investigation]
  enum status: [:open, :closed]

  belongs_to :customer
  belongs_to :review
  belongs_to :assigned_to, class_name: 'User'
  belongs_to :created_by, class_name: 'User'

  has_many :comments, as: :discussable

  validates :title, :task_type, :status, :customer_id, :created_by_id, :assigned_to_id, presence: true
  validates :review_id, presence: true, if: proc { !general? && Rails.env != 'test' }

  scope :order_by_flag, -> { order(flag: :desc) }
  scope :ordered,       -> { order(created_at: :desc) }
  scope :overdue,       -> { where('due_date < ?', Date.today) }
  scope :outstanding,   -> { where.not(status: Task.statuses[:closed]) }

  has_paper_trail only: [:title, :assigned_to_id, :due_date, :status], on: [:create, :update]

  attr_accessor :users_collection

  pg_search_scope :task_search,
    associated_against: {
      assigned_to: [:first_name, :last_name],
      created_by: [:first_name, :last_name]
    },
    against: [:title],
    using: {
      tsearch: { prefix: true }
    }

  def safe_comments
    review&.comments || comments
  end

  def self.statuses_collection
    Task.statuses.keys.map { |t| [I18n.t("activerecord.attributes.task.statuses.#{t}"), t] }
  end

  def self.types_collection
    Task.task_types.keys.map { |t| [I18n.t("activerecord.attributes.task.types.#{t}"), t] }
  end

  def self.assigned_collection(tasks)
    tasks.map(&:assigned_to).compact.uniq.map { |user| [user.decorate.safe_name, user.id] }.sort { |a, b| a[0] <=> b[0] }
  end

  def overdue?
    return false if due_date.blank?

    Date.today > due_date
  end

  def update_review_status(status)
    review.update_attribute(:status, status)
  end
end
