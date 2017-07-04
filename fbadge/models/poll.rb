class Poll < ApplicationRecord
  belongs_to :event

  has_many :poll_sessions, dependent: :destroy
  has_many :answers, dependent: :destroy

  validates :question, presence: true, length: { maximum: 80 }

  accepts_nested_attributes_for :answers, allow_destroy: true, limit: 6

  scope :ordered, -> { order('passing_date DESC NULLS LAST, created_at DESC') }
end
