class Outcome < ActiveRecord::Base

  has_ancestry

  validates :value, presence: true

  scope :roots, -> { where(ancestry: nil).order(id: :asc) }

  acts_as_api

  api_accessible :default do |a|
    a.add :id
    a.add :value
    a.add :children
  end

end
