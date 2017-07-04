class Account < ApplicationRecord
  include Providerable
  belongs_to :customer

  has_many :owned_pages, dependent: :destroy
  has_many :pages, through: :owned_pages
  has_many :analytics_configs, dependent: :destroy

  devise :omniauthable, omniauth_providers: [:facebook, :twitter, :google_oauth2, :linkedin]
  scope :connected, -> { where.not(customer_id: nil) }
  scope :with_invalid_token, -> { where(active: false) }
  scope :with_valid_token, -> { where(active: true) }
  validates :uid, :token, presence: true

  scope :ordered, -> { order(name: :asc) }

  def analytics_config
    analytics_configs.first
  end

  def disable!
    update_attribute(:active, false)
  end

  def expired?
    expires_at < Time.zone.now
  end

  def has_fb_ad_accounts?
    fb_ad_accounts_hash.present?
  end

  def fb_ad_accounts_hash
    JSON.parse(fb_ad_accounts)
  end
end
