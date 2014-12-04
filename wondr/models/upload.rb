class Upload < ActiveRecord::Base

  belongs_to :post

  has_and_belongs_to_many :students
  before_destroy { students.clear }

  mount_uploader :file, FileUploader

  acts_as_api

  api_accessible :default do |a|
    a.add :id
    a.add :description
    a.add :student_ids
    a.add :created_at
    a.add :image
  end

  def image
    file.url(:preview)
  end
end
