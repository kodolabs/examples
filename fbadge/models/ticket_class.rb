class TicketClass < ApplicationRecord
  belongs_to :event
  has_many :tickets, dependent: :destroy

  validates :name, :event, :quantity_total, presence: true
  validates :eventbrite_id, uniqueness: true

  scope :ordered, -> { order(sales_start: :desc) }

  def purchased_quantity
    tickets.count
  end
end
