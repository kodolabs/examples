class Parent < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  validates :first_name, :last_name, presence: true

  has_and_belongs_to_many :students
  before_destroy { students.clear }

  scope :sorted, -> { order('first_name, last_name') }

  acts_as_api

  api_accessible :default do |a|
    a.add :id
    a.add :first_name
    a.add :last_name
    a.add :full_name
    a.add :email
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
