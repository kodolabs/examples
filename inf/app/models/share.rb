class Share < ApplicationRecord
  belongs_to :customer
  belongs_to :shareable, polymorphic: true
  has_many :publications, dependent: :destroy
  has_many :owned_pages, through: :publications
  has_many :campaigns, through: :publications

  default_scope { where(deleted: false) }
  scope :connected, -> { joins(:owned_pages).where('owned_pages.account_id IS NOT NULL') }
  scope :demo, -> { joins(:customer).where(customers: { demo: true }) }

  def in_future?
    scheduled_at.present? && scheduled_at > Time.current
  end

  def expired?
    scheduled_at.present? && scheduled_at < Time.current
  end

  def already_posted?
    !in_future?
  end

  def can_be_deleted?
    in_future? ? true : no_pending_publications?
  end

  def no_pending_publications?
    publications.pending.none?
  end

  def only_linkedin?
    owned_pages.presence && owned_pages.linked_in == owned_pages
  end
end
