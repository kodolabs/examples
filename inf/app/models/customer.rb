class Customer < ApplicationRecord
  include Verificable
  include PgSearch

  has_one :subscription, dependent: :destroy
  has_one :plan, through: :subscription
  has_one :referral_balance, dependent: :destroy
  has_many :cards, dependent: :destroy
  has_many :referrals, foreign_key: 'referrer_id', dependent: :destroy
  has_many :referral_transactions, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :owned_pages, through: :accounts
  has_many :analytics_configs, through: :accounts
  has_many :publications, through: :owned_pages
  has_many :pages, through: :owned_pages
  has_many :posts, through: :pages
  has_many :feeds, dependent: :destroy
  has_many :articles, dependent: :destroy
  has_many :resolved_items, dependent: :destroy
  has_many :profile_topics, through: :users
  has_many :topics, through: :profile_topics
  has_many :publications, through: :shares
  has_many :shares, dependent: :destroy
  has_many :verifications, dependent: :destroy
  has_many :payments, through: :subscription

  mount_uploader :logo, CustomerLogoUploader
  validates :logo, file_size: { less_than: 5.megabytes }
  validates :referral_code, uniqueness: true, on: :update

  after_create :create_feed, :create_balance, :generate_referral_code
  scope :success_registered, -> { joins(users: :profile) }
  scope :ordered, -> { order(:created_at) }
  scope :referrers, -> { joins(:referrals).group(:id).order('referrals.count desc') }
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  delegate :stripe_plan_id, to: :subscription, allow_nil: true
  delegate :email, to: :primary_user, allow_nil: true

  accepts_nested_attributes_for :users
  attr_accessor :full_name
  class << self
    def search(query)
      if query.present?
        numeric?(query) ? search_phone(query) : search_customers(query)
      else
        all
      end
    end

    def numeric?(query)
      query.gsub(/\+*\-*\s*/, '').match(/^[0-9]+$/)
    end

    def search_phone(query)
      normalized_phone = Phony.normalize(query) rescue query
      where('profiles.phone LIKE ?', "%#{normalized_phone}%")
    end

    def search_customers(query)
      success_registered
        .where('LOWER(users.email) LIKE :q
          OR LOWER(profiles.full_name) LIKE :q', q: "%#{query.strip.downcase}%")
    end
  end

  def facebook_account
    accounts.facebook.first
  end

  def linkedin_account
    accounts.linkedin.first
  end

  def twitter_accounts
    accounts.twitter
  end

  def google_accounts
    accounts.google
  end

  def google_account
    google_accounts.first
  end

  def twitter_account
    accounts.twitter.first
  end

  def primary_user
    users.first
  end

  def primary_feed
    feeds.first
  end

  def valid_subscription?
    if subscription.present?
      subscription.try(:plan_id).present? && !subscription.expired?
    else
      return false if trial_ends_on.blank?
      trial_not_expired?
    end
  end

  def trial_not_expired?
    trial_ends_on.end_of_day > Time.current
  end

  def trial?
    trial_ends_on.presence && trial_not_expired?
  end

  def reached_account_limit?
    return unless subscription
    owned_pages.count >= subscription.max_accounts
  end

  def any_account?
    owned_pages.size.positive?
  end

  def default_card
    cards.find_by(default: true) || cards.first
  end

  def unverified?
    verifications.blank? || declined?
  end

  def verified?
    verifications.any? && !declined?
  end

  def campaigns
    Campaign.where('publication_id IN (?)', publications.select(:id))
  end

  def activate
    update_attributes(active: true)
  end

  def deactivate
    transaction do
      update_attributes!(active: false)
      return true if subscription.blank?
      cancel_res = StripeService::Subscription.new(self).cancel(subscription.stripe_id)
      raise ActiveRecord::Rollback unless cancel_res
      subscription.destroy!
    end
  end

  def google_analytics?
    analytics_configs.any?
  end

  def generate_demo_token
    value = demo ? unique_code : nil
    update_attribute(:demo_token, value)
  end

  def self.primary_demo_account
    where(demo: true).last
  end

  def send_notification
    NotificationMailer.new_customer(self).deliver_later
  end

  def has_fb_ad_accounts?
    accounts.facebook.map(&:has_fb_ad_accounts?).reduce(&:|)
  end

  def inactive?
    !active?
  end

  private

  def create_feed
    feeds.create
  end

  def create_balance
    create_referral_balance
  end

  def generate_referral_code
    update_attribute(:referral_code, unique_code)
  end

  def unique_code
    Hashids.new(id.to_s, 10).encode(0)
  end
end
