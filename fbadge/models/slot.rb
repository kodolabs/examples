class Slot < ApplicationRecord
  belongs_to :location

  validates :begins_at, :ends_at, presence: true
end
