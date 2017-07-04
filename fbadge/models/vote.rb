class Vote < ApplicationRecord
  belongs_to :poll_session
  belongs_to :registration
  has_many :vote_answers, dependent: :destroy

  validates :registration, :poll_session, presence: true
  validates :registration_id, uniqueness: { scope: :poll_session_id }
  validate :active_poll_session

  scope :by_poll_session, -> (poll_session) { where(poll_session: poll_session) }

  private

  def active_poll_session
    errors.add(:poll_session, 'is not active') unless poll_session.active?
  end
end
