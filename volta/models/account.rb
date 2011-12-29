class Account < ActiveRecord::Base
  include ApiKeyHelper
  include ApplicationHelper

  acts_as_api

  belongs_to :owner,              :class_name => 'User'

  has_many :calls,                :order => "updated_at DESC",        :dependent => :destroy
  has_many :rings,                :through => :calls
  has_many :events,               :order => "name",                   :dependent => :destroy
  has_many :customers,            :order => "last_name, first_name",  :dependent => :destroy
  has_many :categories,           :order => "name",                   :dependent => :destroy
  has_many :users,                :order => "last_name, first_name",  :dependent => :destroy
  has_many :departments,          :order => "name",                   :dependent => :destroy

  validates :company,             :presence => true, :uniqueness => true
  validates :country,             :presence => true
  validates :state,               :presence => true
  validates :city,                :presence => true
  validates :address,             :presence => true

  validates :phone, :length => { :minimum =>  10, :message => "Phone number should contain 10 digits", :allow_nil => true}

#  validates :address2,            :presence => true

#  validates :phone,               :presence => true
#  validates :expiration_month,    :presence => true, :on => :create
#  validates :expiration_year,     :presence => true, :on => :create
#  validates :credit_card_number,  :presence => true, :on => :create
#  validates :cvv,                 :presence => true, :on => :create

  attr_accessor :expiration_month, :expiration_year, :credit_card_number, :cvv

  scope :by_id, lambda {|id| {:conditions => {:id => id}} unless id.nil? }
  scope :by_company, lambda {|company| {:conditions => ["company LIKE ?", company + "%"]} unless company.nil? }
  scope :active, :conditions => { :active => true }
  scope :inactive, :conditions => { :active => false }

  accepts_nested_attributes_for :owner

  before_create :set_defaults

  before_validation :prepare_phone

  def prepare_phone
    self.phone = prepare_phone_number(self.phone)
  end

  def create_and_subscribe(product_id)
    return unless self.valid?
    Account.transaction do
      self.save
      subscription = Chargify::Subscription.new(subscription_params(product_id))
      if subscription.save
        self.update_attributes!(:customer_id => subscription.customer.id, :subscription_id => subscription.id)
      else
        subscription.errors.full_messages.each{|err| errors.add_to_base(err)}
        false
        raise ActiveRecord::Rollback
      end
    end
  end

  def subscription
    Chargify::Subscription.find(subscription_id)
  end

  def customer
    Chargify::Customer.find(customer_id)
  end

  api_accessible :default do |template|
    template.add :company
    template.add :address
    template.add :address2
    template.add :city
    template.add :state
    template.add :phone
    template.add :contact_person
  end

protected

  def set_defaults
    self.active = true
  end

private

  def customer_params
    {
      :first_name   => owner.first_name,
      :last_name    => owner.last_name,
      :email        => owner.email,
      :reference    => id,
      :organization => "",
    }
  end

  def subscription_params(product_id)
    {
      :product_id => product_id,
      :customer_attributes => customer_params,
      :credit_card_attributes => {
        :full_number => credit_card_number,
        :cvv => cvv,
        :expiration_month => expiration_month,
        :expiration_year => expiration_year
      }
    }
  end
end
