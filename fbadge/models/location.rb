class Location < ApplicationRecord
  belongs_to :event
  has_many :slots, dependent: :destroy

  validates :name, :event, presence: true
end
