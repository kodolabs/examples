class Topic < ActiveRecord::Base

  validates :title, presence: true

  acts_as_api

  api_accessible :default do |a|
    a.add :id
    a.add :title
  end

end
