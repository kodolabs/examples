class Klass < ActiveRecord::Base

  validates :name, :year, presence: true

  has_many :students, dependent: :nullify

  has_and_belongs_to_many :admins
  before_destroy { admins.clear }

  scope :sorted, -> { order(name: :asc) }

  acts_as_api

  api_accessible :default do |a|
    a.add :id
    a.add :name
    a.add :year
    a.add :location
    a.add :students
    a.add :admin_ids
  end
end
