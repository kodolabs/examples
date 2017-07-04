class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  has_one :organiser, dependent: :destroy

  has_many :profiles, dependent: :destroy
  has_many :events, through: :profiles, dependent: :nullify

  validates :name, :surname, :phone, presence: true

  scope :ordered, -> { order(surname: :asc) }

  def authorized_organiser?
    organiser.present? && organiser.eventbrite_token.present?
  end

  def pending_eventbrite_auth?
    organiser.present? && organiser.eventbrite_token.blank?
  end

  def official_name
    "#{surname}, #{name}"
  end

  def full_name
    "#{name} #{surname}"
  end

  def last_login_date
    if last_sign_in_at.blank?
      'N/A'
    else
      "#{last_sign_in_at.to_s(:short)} #{last_sign_in_at.to_s(:time)}"
    end
  end

  def profile_attributes
    { name: name, surname: surname, phone: phone }
  end

  def event_organiser_profile(event)
    profiles.find_by(event_id: event.id, role: 'organiser')
  end
end
