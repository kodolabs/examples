class Call < ActiveRecord::Base
  include ApplicationHelper
  acts_as_api

  ASSIGN_PERIOD = 10 * 60 # 10 minutes

  STATUSES = %w{pending assigned calling done}

  belongs_to  :account
  belongs_to  :customer
  belongs_to  :event
  belongs_to  :phone
  belongs_to  :script
  belongs_to  :user, :counter_cache => true

  has_many    :rings, :dependent => :destroy

  delegate :name, :to => :customer, :prefix => 'customer'

  default_scope         order("#{self.table_name}.updated_at DESC")

  scope :today,         where("#{self.table_name}.created_at BETWEEN ? AND ?", Date.today.beginning_of_day, Date.today.end_of_day)
  scope :active,        where(:status => ['pending', 'assigned', 'calling'])
  scope :archived,      where(:status => 'done' )
  scope :pending,       where(:status => 'pending').order('updated_at ASC')
  scope :recent,        order("#{self.table_name}.created_at DESC").limit(10)
  scope :scheduled,     where("scheduled_at <= ?", Time.now)

  scope :range,         lambda {|range|       where(:created_at => range) unless range.blank? }
  scope :by_event,      lambda {|event_id|    where(:event_id => event_id) unless event_id.blank? }
  scope :by_user,       lambda {|user_id|     where(:user_id => user_id) unless user_id.blank? }
  scope :by_account,    lambda {|account|     where(:account_id => account.id) unless account.blank? }
  scope :by_customer,   lambda {|customer_id| where(:customer_id => customer_id) unless customer_id.blank? }

  scope :unassigned_or_belongs_to, lambda {|user_id|     where("user_id IS NULL or user_id=?", user_id) unless user_id.blank? }

  validates :account_id, :presence => true
  validates :customer_id, :presence => true
  validates :event_id, :presence => true
  validates :phone_id, :presence => true
  validates :script_id, :presence => true
  validates :description, :presence => true

  before_create :set_scheduled_at

  def set_scheduled_at
    self.scheduled_at = Time.now
  end

  attr_accessor :close

  api_accessible :default do |template|
    template.add :id
    template.add :phone
    template.add :script
    template.add :description
    template.add :event
    template.add :customer
    template.add :status
    template.add :success
    template.add :scheduled_at
    template.add :created_at
    template.add :user
  end

  # statuses: pending, assigned, calling, done
  state_machine :status, :initial => :pending do
    event :assign do
      transition [:pending] => :assigned, :if => :user_assigned?
    end

    event :call do
      transition [:assigned] => :calling
    end

    event :finish do
      transition all => :done
    end

    event :retry do
      transition [:assigned, :calling] => :pending, :unless => :user_assigned?
    end

    event :requeue do
      transition [:done] => :pending
    end

    event :reschedule do
      transition [:pending, :assigned] => :pending, :if => :scheduled?
    end
  end

  def event_name
    self.event.name
  end

  def close=(really)
    finish! if really
  end

  def assign_user(user)
    if pending?
      self.user = user
      self.assigned_until = Time.now + ASSIGN_PERIOD
      assign!
      save
    end
  end

  def user_assigned?
    !user.nil?
  end

  def scheduled?
    scheduled_at.present? && scheduled_at >= Time.now
  end

  def unassign_user
    self.user = nil
    self.assigned_until = nil
    retry!
    save
  end

  def start_call
    if @assigned_until and Time.parse(@assigned_until) < Time.now
      raise "Assign period finished"
    end
    call!
  end

  def finish_call(succeeded)
    self.assigned_until = nil
    if succeeded
      finish!
    else
      self.user = nil
      retry!
    end
    save
  end

  def do_not_call
    # TODO: this method might need some extending
    # for instance, if there is any special handing required to such calls
    update_attributes :success => false, :scheduled_at => nil
    finish!
  end

  #convenient method for debugging
  def debug_reset
    self.update_attributes!({:status=>"pending", :user_id=>nil, :scheduled_at=>nil, :success=>nil})
  end

  def self.assign_pending_call(user)
    call = Call.active.pending.first
    call.assign_user user unless call.nil?
    call
  end

  # load other calls related to same customer, excluding current
  def self.history(call, limit = 10)
    self.where("customer_id = ? AND id <> ?", call.customer_id, call.id).limit(limit) # unless call.customer.blank?
  end

  def self.generate(account)
    call = self.new
    call.description = Faker::Lorem.paragraphs(3).join("\n")
    call.account     = account
    call.customer    = Customer.generate(account) #account.customers.random.first unless account.customers.empty?
    call.event       = account.events.random.first unless account.events.empty?
    call.script      = call.event.scripts.random.first unless call.event.blank? or call.event.scripts.empty?
    call.phone       = call.customer.phones.first unless call.customer.phones.empty?
    call
  end

  def self.create_with_raw_data(data)
    # TODO: validate data fields

    first_name    = data.delete('first_name')
    last_name     = data.delete('last_name')
    phone_number  = prepare_phone_number(data.delete('phone_number'))

    account      = Account.find(data['account_id'])
    customer     = Customer.find_or_create( { :account_id => account.id, :first_name => first_name, :last_name => last_name } )
    phone        = Phone.find_or_create( {:customer_id => customer.id, :number => phone_number})

    call = self.new(data)
    raise "Invalid call type ID" if call.event.nil?
    call.customer = customer
    call.phone = phone
    call.script = call.event.scripts.first
    call.save!
    call
  end

  def self.report_for(account, options = {})
    report = self.by_account(account).
            range(options[:range]).
            by_event(options[:event]).
            by_user(options[:user]).
            select("DATE(created_at), COUNT(*) AS count").
            group("DATE(created_at)")

    report = report.inject(Hash.new{|h,k| h[k] = 0}) {|map, object| map[object.attributes['DATE(created_at)']] = object.count; map }

    for day in options[:range]
      report[day] = 0 if report[day].nil?
    end

    report.sort
  end

  private

  #def validate_account
  #  if self.account_id != self.event.account_id
  #    self.errors.add(:event_id, "Event #{self.event_id} does not belong to account #{self.account_id}")
  #    false
  #  end
  #
  #  if self.account_id != self.customer.account_id
  #    self.errors.add(:customer_id, "Customer #{self.customer_id} does not belong to account #{self.account_id}")
  #    false
  #  end
  #end

end