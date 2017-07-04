class User < ApplicationRecord
  SYNC_DB_ATTRS = %w[email encrypted_password]

  include DbSyncable

  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :validatable, :confirmable

  belongs_to :customer
  has_one :profile, dependent: :destroy, class_name: '::Profile'
  has_many :profile_topics, through: :profile
  # validates :full_name, presence: true # TODO: uncomment after migration ran on servers

  accepts_nested_attributes_for :customer, allow_destroy: false

  def inactive?
    customer&.inactive?
  end
end
