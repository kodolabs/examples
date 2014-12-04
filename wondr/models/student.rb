class Student < ActiveRecord::Base

  validates :last_name, :first_name, presence: true

  belongs_to :klass

  has_and_belongs_to_many :parents
  has_and_belongs_to_many :uploads
  has_and_belongs_to_many :posts # direct association with Quote

  before_destroy { parents.clear }
  before_destroy { uploads.clear }

  scope :sorted, -> { order(first_name: :asc, last_name: :asc) }

  mount_uploader :avatar, AvatarUploader

  acts_as_api

  api_accessible :default do |a|
    a.add :id
    a.add :klass_id
    a.add :klass_name
    a.add :first_name
    a.add :last_name
    a.add :full_name
    a.add :id_number
    a.add :dob
    a.add :posts_count
    a.add :avatar_thumb
    a.add :parent_ids
  end

  def posts_count
    0
  end

  def klass_name
    klass.name unless klass.blank?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def avatar_thumb
    avatar.thumb.url
  end
end
