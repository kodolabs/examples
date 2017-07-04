class PollSession < ApplicationRecord
  belongs_to :poll
  has_many :votes, dependent: :destroy
  has_many :answers, through: :poll

  validates :poll, presence: true
  validate :active_poll_sessions

  enum status: { active: 0, closed: 1 }

  scope :ordered, -> { order(:position) }

  before_create :set_position

  private

  def active_poll_sessions
    active_sessions = poll.poll_sessions.active.where.not(id: id).present?
    errors.add(:poll_session, 'has another active session at the moment') if active_sessions
  end

  def set_position
    collection = poll.poll_sessions.ordered
    self.position = collection.last.position + 1 if collection.present?
  end
end
