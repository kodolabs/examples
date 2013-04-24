class User < ActiveRecord::Base

  has_many :phones
  has_many :messages
  has_many :greetings
  has_many :schedules

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :role, :admin, :invitation_token,
                  :phone, :notify_by_email, :notify_by_sms, :time_zone

  attr_accessor :admin, :invitation_token

  validates :name, presence: true

  def admin=(value)
    self.role = value.to_i.zero? || !!value == false ? '' : 'admin'
  end

  def admin
    admin? ? '1' : '0'
  end

  def admin?
    role == 'admin'
  end

  def add_phone(country)
    phone = Phone.purchase country
    self.phones << phone
    phone
  end

  def greeting
    scheduled_greeting || greetings.active.first || greetings.last
  end

  def scheduled_greeting
    active = schedules.active
    active.first.greeting unless active.blank? || active.first.greeting.blank?
  end
end
