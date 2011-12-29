class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :gpc_number, :terms, :perms, :address_attributes, :current_password, :invite, :notes, :new_administrator_notification_needed, :role
  attr_accessor :current_password, :invite, :new_administrator_notification_needed, :force_password_required
  attr_writer :administrator_of

  has_many  :memberships,       :dependent  => :destroy
  has_many  :organisations,     :through    => :memberships
  has_many  :membership_roles,  :through    => :memberships
  has_one   :address,           :dependent  => :destroy, :as => :addressable
  has_many  :assessments,       :dependent  => :destroy
  has_many  :purchases,         :dependent  => :destroy, :as => :purchaser
  has_many  :payments,          :dependent  => :destroy
  has_many  :rights,            :dependent  => :destroy
  has_many  :orders,            :dependent  => :destroy
  has_many  :sagepay_payments,  :dependent  => :destroy

  has_many  :trainings

  validates :name, :presence => true
  validates :gpc_number,
            :presence => {:unless => lambda {|user| @administrator_of.present? || user.administrator?}},
            :uniqueness => {:unless => lambda {|user| @administrator_of.present? || user.administrator?}, :message => "Number already registered. Please note Superintendent Pharmacists / Pharmacist Owners are automatically registered as PGD-using Pharmacists."}
  validates :email, :presence => true, :uniqueness => true
  validates :terms, :acceptance => { :accept => true }
  validates :password_confirmation, :presence => {:if => lambda {|user| user.password_required?}}

  scope :pharmacists,           select("distinct users.*").joins(:membership_roles).where(['membership_roles.role = ?', MembershipRole::PHARMACIST])
  scope :administrators,        select('distinct users.*').joins(:membership_roles).where(['membership_roles.role = ?', MembershipRole::ADMINISTRATOR])
  scope :by_name,               lambda {|name| where ['name like ?', "%#{name}%"]}
  scope :by_organisation_name,  lambda {|name| joins(:organisations).where(['organisations.name like ?', "%#{name}%"])}
  scope :pharmacists_of,        lambda {|org| joins(:organisations).joins(:membership_roles).where(['organisations.id = ? and membership_roles.role = ?', org, MembershipRole::PHARMACIST]).group(:id)}
  scope :administrators_of,     lambda {|org| joins(:organisations).joins(:membership_roles).where(['organisations.id = ? and membership_roles.role = ?', org, MembershipRole::ADMINISTRATOR]).group(:id)}
  scope :staff_of,              lambda {|org| joins(:organisations).where(['organisations.id = ?', org]).group(:id)}

  delegate :city, :country, :postcode, :telephone_1, :to => :address

  before_validation :format_fields, :on => :create

  # following code only tested with devise v=1.1.5 and DOES NOT work with 1.3.x
  before_validation(:on => :update) do
    return if current_password.nil?
    salt = self.password_salt
    self.password_salt = password_salt_was
    errors[:current_password] << "doesn't match actual password" unless password_digest(current_password) == encrypted_password_was
    self.password_salt = salt
  end

  after_create :accept_invitation, :become_administrator, :send_welcome_notification, :notify_new_administrator

  accepts_nested_attributes_for :address

  comma do
    name
    email
  end

  # can't delegate it as names are the same
  def street_address
    address.address
  end

  def format_fields
    self.name = self.name.split(" ").map{|word| word.capitalize}.join(" ") unless self.name.blank?
  end

  def discount
    0
  end

  def terms=(value)
    write_attribute :terms, value == '1'
  end

  def terms
    read_attribute :terms
  end

  def superintendent_of
    organisations = []
    self.memberships(true).undeleted.with_pharmacist_role.each do |membership|
      organisations << membership.organisation if membership.organisation.superintendent_id == self.id
    end
    organisations.first
  end

  def administrator_of
    organisations = []
    self.memberships(true).undeleted.with_administrator_role.each do |membership|
      organisations << membership.organisation
    end
    organisations.first
  end

  def superintendent?
    superintendent_of.present?
  end

  def new_superintendent?
    if superintendent?
      return superintendent_of.superintendent_confirmation
    end
    false
  end

  def administrator?
    administrator_of.present?
  end

  def pharmacist?
    self.memberships(true).undeleted.with_pharmacist_role.present? || self.memberships.blank?
  end

  def pharmacist_of?(organisation)
    self.memberships(true).undeleted.with_pharmacist_role.each do |membership|
      return true if membership.organisation == organisation
    end
    false
  end

  def administrator_of?(organisation)
    self.memberships(true).undeleted.with_administrator_role.each do |membership|
      return true if membership.organisation == organisation
    end
    false
  end

  def accept_invitation
    unless invite.blank?
      organisation = Organisation.find_by_invite_key(invite)
      unless organisation.blank?
        membership = self.memberships.create :organisation => organisation
        membership.is_pharmacist
      end
    end
  end

  def send_welcome_notification
    send_confirmation_instructions unless @administrator_of.present?
  end

  def notify_new_administrator
    Mailer.new_administrator(self).deliver if @administrator_of.present? && new_administrator_notification_needed == '1'
  end

  def become_associated_with(organisation, permission = "1")
    membership = self.memberships.find_by_organisation_id(organisation.id)

    if membership.blank?
      membership = self.memberships.build(:permission => permission)
      membership.organisation = organisation
      organisation.memberships.reload
    end

    membership.is_pharmacist if membership.save
    membership
  end

  def become_associated_with!(organisation, permission = "1")

    membership = self.memberships.build(:permission => permission)
    membership.organisation = organisation

    membership.is_pharmacist if membership.save!
    membership
  end

  def payment_by_pgd_and_organisation(pgd, organisation)
    self.payments.valid.by_pgd(pgd.id).by_organisation(organisation).first
  end

  def right_by_pgd_and_organisation(pgd, organisation)
    self.rights.valid.by_pgd(pgd.id).by_organisation(organisation).first
  end

  def active?
    super && !suspended?
  end

   def inactive_message
     suspended? ? 'Access for your organisation is suspended.' : super
   end

   def suspended?
     false
   end

   def to_s
     name
   end

   def become_administrator
     if @administrator_of.present? && @administrator_of.is_a?(Organisation)
       membership = @administrator_of.memberships.build :user => self
       if membership.save
         membership.is_administrator
       end
     end
   end

   def send_confirmation_instructions
     generate_confirmation_token! if self.confirmation_token.nil?
     Mailer.confirmation_instructions(self).deliver
   end

  def send_reset_password_instructions
    generate_reset_password_token!
    Mailer.reset_password_instructions(self).deliver
  end

  def self.find_or_initialize_with_error_by(attribute, value, error=:invalid)
    user = super
    user.force_password_required = true if attribute == :reset_password_token
    user
  end

  def password_required?
    !persisted? || password.present? || password_confirmation.present? || force_password_required
  end

  def confirmation_required?
    false
  end

  def printable_address
    address.printable unless address.blank?
  end

  def first_name
    name.match(/^(.+)\s\S+$/).try(:[], 1) || '[your name]'
  end

  def last_name
    name.match(/^.+\s(\S+)$/).try(:[], 1) || name
  end

  def is_previewer?
    role == 'previewer'
  end
end
