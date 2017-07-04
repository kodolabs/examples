class Category < ApplicationRecord
  has_many :featured_pages_categories, dependent: :destroy
  has_many :featured_pages, through: :featured_pages_categories
  has_many :category_topics, dependent: :destroy
  has_many :topics, through: :category_topics

  validates :title, presence: true, uniqueness: true

  scope :ordered, -> { order(:position) }
  scope :with_featured_pages, lambda {
                                includes(:featured_pages_categories)
                                  .where.not(featured_pages_categories: { category_id: nil })
                              }

  before_create :set_category_position

  private

  def set_category_position
    self.position = Category.all.empty? ? 0 : Category.count
  end
end
