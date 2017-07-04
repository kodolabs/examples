class Publication < ApplicationRecord
  belongs_to :share
  belongs_to :owned_page
  belongs_to :published_post, optional: true, class_name: 'Post'
  has_one :campaign, dependent: :destroy

  delegate :facebook?, to: :provider
  delegate :linkedin?, to: :provider
  delegate :customer, to: :account
  delegate :shareable, to: :share
  scope :ordered, -> { order(created_at: :desc) }
  enum status: { pending: 0, success: 1, error: 2 }

  delegate :provider, to: :owned_page

  delegate :account, to: :owned_page
end
