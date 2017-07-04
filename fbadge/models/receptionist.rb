class Receptionist < ApplicationRecord
  belongs_to :event

  validates :name, :email, :token, presence: :true
  validates :email, format: { with: /\A\S+@.+\.\S+\z/ }

  scope :ordered, -> { order(name: :asc) }

  def reception_link
    "http://#{ENV['RECEPTION_HOST_NAME']}/events/#{event.token}/#{token}"
  end
end
