class Gallery < Post
  validates :name, :description, presence: true
end
