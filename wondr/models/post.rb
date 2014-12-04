class Post < ActiveRecord::Base

  has_many :uploads, dependent: :destroy

  has_and_belongs_to_many :students # this only used by Quote model
  before_destroy { students.clear }

  attr_accessor :uploads_data

  scope :sorted, -> { order(:created_at => :desc) }

  after_save :update_uploads

  acts_as_api

  api_accessible :default do |a|
    a.add :id
    a.add :type
    a.add :name
    a.add :description
    a.add :uploads
    a.add :created_at
    a.add :student_ids
  end

  def update_uploads
    return if uploads_data.blank?

    uploads_data.each do |row|
      upload = Upload.find row[:id]
      attributes = row.merge post_id: id
      upload.update_attributes attributes
    end
  end

end
