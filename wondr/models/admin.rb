class Admin < ActiveRecord::Base

  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  enum role: [:admin, :user]

  validates :first_name, :last_name, presence: true

  has_and_belongs_to_many :klasses
  before_destroy { klasses.clear }

  scope :sorted, -> { order('first_name, last_name')}

  before_validation :set_defaults

  acts_as_api

  api_accessible :default do |a|
    a.add :id
    a.add :first_name
    a.add :last_name
    a.add :full_name
    a.add :email
    a.add :created_at
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def set_defaults
    self.password = 'password'
    self.role = :user
  end

end
