class OwnedPage < ApplicationRecord
  belongs_to :account
  belongs_to :page
  has_many :publications, dependent: :destroy

  attr_accessor :checked

  scope :facebook, -> { by_provider(:facebook) }
  scope :twitter, -> { by_provider(:twitter) }
  scope :linked_in, -> { by_provider(:linkedin) }
  scope :connected, -> { where.not(account_id: nil) }

  def self.by_provider(provider)
    joins(account: [:provider]).where(providers: { name: provider })
  end

  def provider
    account&.provider
  end
end
