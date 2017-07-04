class Article < ApplicationRecord
  belongs_to :customer
  has_many :publications, through: :shares
  has_many :shares, as: :shareable, dependent: :destroy
  has_many :images, dependent: :destroy, class_name: ArticleImage

  validates :title, :content, presence: true
  paginates_per 10

  has_many :owned_pages, through: :publications
  has_many :campaigns, through: :publications

  scope :scheduled, -> { where.not(shares: { scheduled_at: nil }) }
  scope :not_scheduled, -> { where(shares: { scheduled_at: nil }) }
  scope :ordered, -> { order(created_at: :desc) }

  def title
    content.truncate(30)
  end

  def primary_share
    shares.first
  end
end
