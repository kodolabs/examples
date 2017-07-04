class Answer < ApplicationRecord
  belongs_to :poll

  has_many :vote_answers
  has_many :votes, through: :vote_answers

  validates :position, :value, presence: true
  validates :value, length: { maximum: 20 }
end
