require 'pp'

class Order < ActiveRecord::Base

  DEFAULT_CURRENCY = 'GBP'

  PENDING   = 'pending'
  PAID      = 'paid'
  REFUND    = 'refund'
  PAYMENT_STATUSES  = [PENDING, PAID, REFUND]

  CARD_TYPES = ["Visa", "Mastercard", "Mastercard Debit", "Delta", "Electron", "Maestro", "Purchasing"]

  DELIVERY_DESTINATION = {
    'UK' => 1,
    'EU' => 2,
    'RoW' => 5
  }

  belongs_to :site
  belongs_to :customer
  belongs_to :discount, counter_cache: true

  has_one :delivery_address, class_name: 'Address', as: :addressable
  has_one :job

  has_many :items, class_name: 'OrderItem', dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :adjustments, dependent: :destroy
  has_many :order_notifications, dependent: :destroy

  mount_uploader :job_sheet,  JobSheetUploader

  validates :total, numericality: true, presence: true
  validates :payment_status, inclusion: { in: PAYMENT_STATUSES }, presence: true
  validates :site_id, presence: true
  validates :customer_id, :delivery_address, presence: true
  validates :country, :street, :postal_code, :city, presence: true

  validates :card_type, :number, :security_code, :valid_until_month, :valid_until_year, :fullname, presence: true, on: :create, if: :requires_card_validation

  before_validation :set_default_payment_status, on: :create
  before_validation :set_default_status, on: :create
  before_validation :set_totals
  before_validation :set_customer_fields

  before_create :set_expected_delivery_date
  after_create  :send_admin_notification

  scope :by_payment_status, lambda { |payment_status| where(payment_status: payment_status) }
  scope :by_status,   lambda { |status|       where(status: status) }
  scope :by_site,     lambda { |site_id|      where(site_id: site_id) }
  scope :by_customer, lambda { |customer_id|  where(customer_id: customer_id ) }
  scope :by_created_at, lambda{ |created_at| where( "DATE(created_at) = DATE(?)", created_at.to_date )}

  scope :paid, where(payment_status: 'paid')
  scope :dispatched, where(status: 'dispatched')
  scope :in_progress, where('status != "dispatched"')

  delegate :name, to: :customer, prefix: true, allow_nil: true
  delegate :email, to: :customer, allow_nil: true

  attr_accessor :card_type, :number, :security_code, :valid_until_month, :valid_until_year, :fullname, :validate_payment_data, :issue_number # fields for Xpay::Customer and XPay::Card
  attr_accessor :promo_code, :use_delivery_address

  attr_accessible :card_type, :number, :security_code, :valid_until_month, :valid_until_year, :fullname, :issue_number,
                  :promo_code, :use_delivery_address, :country, :county, :company, :street, :address2, :postal_code,
                  :city, :issue_number, :site, :customer, :job_sheet, :email_message, :notes, :installation, :installation_notes, :preferred_date

  state_machine :status, initial: :new do

    after_transition any => :production do |model, transition|
      model.start_job
    end

    after_transition :production => :canceled  do |model, transition|
      model.cancel_job
    end

    after_transition :production => :dispatched  do |model, transition|
      model.send_dispatch_email
    end

    event :new          do transition any => :new   end
    event :edit         do transition any => :edit  end
    event :production   do transition any => :production  end
    event :cancel       do transition :production => :canceled end
    event :dispatch     do transition :production => :dispatched end
  end

  STATUSES = state_machines[:status].states.map &:name

  state_machine :payment_status, initial: :pending do
    after_transition :pending => :paid do |model, transition|
      model.send_confirmation_email
    end

    event :paid do transition any => :paid end
    event :refund do transition any => :refund end
  end

  define_index do
    indexes items(:wall_code), as: :wall_code
    indexes customer(:first_name)
    indexes customer(:last_name)
    indexes items.orderable.designable(:title)
    indexes :status
    indexes items(:product_name), as: :product_name
    has :created_at, :site_id
    has "CRC32(payment_status)", as: :payment_status, type: :integer
    set_property delta: :delayed
  end


  sphinx_scope :ts_order do |order|
    { order: order, sort_mode: :extended }
  end

  sphinx_scope :ts_by_created_at do |created_at|
    { with: { created_at: created_at.to_date.beginning_of_day..created_at.to_date.end_of_day  } }
  end

  sphinx_scope :ts_by_payment_status do |payment_status|
    { with: { payment_status: payment_status.to_s.to_crc32  } }
  end

  sphinx_scope :ts_by_site do |site_id|
    { with: { site_id: site_id  } }
  end


  def self.build_from(cart, site, customer)
    order                   = Order.new
    order.site              = site
    order.customer          = customer
    order.discount          = cart.discount
    order.delivery_address  = customer.address
    order.billing_address   = customer.address
    order.installation      = cart.installation

    cart.cart_items.each do |cart_item|
      order.items << OrderItem.build_from(cart_item)
    end

    order.set_totals
    order
  end

  def hq_cost
    items.design.map(&:hq_cost).sum
  end

  def wf_cost
    items.design.map(&:wf_cost).sum
  end

  def packing
    items.design.map(&:packing).sum
  end

  def size
    items.size
  end

  def billing_address=(address)
    if address.is_a?(Address)
      self.country     = address.country
      self.county      = address.county
      self.company     = address.company
      self.street      = address.street
      self.address2    = address.address2
      self.postal_code = address.postal_code
      self.city        = address.city
    end

    if address.nil?
      self.country     = nil
      self.county      = nil
      self.company     = nil
      self.street      = nil
      self.address2    = nil
      self.postal_code = nil
      self.city        = nil
    end
  end

  def billing_address
    address = Address.new(
      country:     country,
      county:      county,
      company:     company,
      street:      street,
      address2:    address2,
      postal_code: postal_code,
      city:        city
    )
  end

  def delivery_address=(address)
    self.build_delivery_address(address.public_attributes) if address.is_a?(Address)
  end

  def order_number(display_dash = true)
    "#{display_dash ? '#' : ''}"+id.to_s.rjust(5, '0')
  end

  def valid_until
    "#{valid_until_month}/#{valid_until_year}"
  end

  def payment
    return false unless valid? # running validation will trigger set_totals
    payment = xpay_payment
    begin
      result = payment.make_payment

      case result
        when 0, 2 # processing error, decline
          errors.add(:base, payment.response_block[:error_code])
        when 1 # approve
          @transaction = build_transaction(payment.response_block)

          if @transaction.save
            self.paid!
            return save
          else
            errors.add(:base, @transaction.errors)
          end
        when 3 # 3D-secure
          errors.add(:base, "Attempt to process payment with 3D-Secure - not supported")
        else
          errors.add(:base, "Unknown error")
      end
    rescue
      errors.add(:base, $!.to_s)
    end
    false
  end

  def build_transaction(response)
    transaction             = self.transactions.build
    transaction.reference   = response[:transaction_reference]
    transaction.details     = response
    transaction
  end

  def fields_for_card
    filtered_attributes %w{card_type number security_code valid_until}
  end

  def fields_for_customer
    filtered_attributes %w{fullname firstname lastname street city stateprovince postcode countrycode phone email}
  end

  def fields_for_operation
    {
        auth_type: 'AUTH',
        currency: DEFAULT_CURRENCY,
        amount: (total * 100).to_i,
        order_reference: order_number,
        order_info: order_info
    }
  end

  def firstname
    first_name
  end

  def lastname
    last_name
  end

  def stateprovince
    county
  end

  def postcode
    postal_code
  end

  def countrycode
    country
  end

  def phone
    customer.mobile unless customer.blank?
  end

  def order_info
    items.map{|e| e.orderable.product_name }.join(', ')
  end

  def xpay_payment
    return XpayPaymentStub.new if Rails.env.test? || Rails.env.development?

    Xpay.load_config

    customer  = Xpay::Customer.new fields_for_customer
    card      = Xpay::CreditCard.new fields_for_card
    operation = Xpay::Operation.new fields_for_operation # price in cents

    Xpay::Payment.new(creditcard: card, customer: customer, operation: operation)
  end

  def set_customer_fields
    unless customer.blank?
      self.first_name   = customer.first_name
      self.last_name    = customer.last_name
      self.mobile_phone = customer.mobile
    end
  end

  def set_totals
    cost                = items.map(&:cost).sum.round(2)
    self.discount_value = calculate_discount(cost)
    self.delivery_cost  = DeliveryDiscountCalculator.new(items: items, region: delivery_region, amount: (cost - discount_value) * (1 + PriceCalculator.vat_rate)).cost
    self.free_delivery  = delivery_cost.zero?
    self.subtotal       = (cost + delivery_cost - discount_value).round(2)
    self.vat            = (subtotal * PriceCalculator.vat_rate).round(2)
    self.total          = subtotal + vat
  end

  def sale_amount
    (subtotal.to_f - delivery_cost.to_f).round(2)
  end

  def delivery_with_vat
    delivery_cost * (1 + PriceCalculator.vat_rate)
  end

  def delivery_region
    return Region.for delivery_address.country if delivery_address
    return Region.for country # billing address
    #raise 'No delivery address'
  end

  # State machine callbacks
  def start_job
    create_job
    OrderMailer.job_created(self).deliver
  end

  def cancel_job
    job.destroy
    self.job = nil
    OrderMailer.job_canceled(customer.user.email, self).deliver
    Adjustment.change_amount(-total, id) if paid?
    self.refund!
  end

  def dispatch_with_code(tracking_code)
    unless tracking_code.blank?
      self.tracking_code = tracking_code
      dispatch!
    end
  end

  def send_notfinished_order_email
    OrderMailer.no_return(customer.user.email, self).deliver
    self.order_notifications.create(flag: :notfinished_order)
  end

  def send_ready_to_install_email
    OrderMailer.ready_to_install(customer.user.email, self).deliver
    self.order_notifications.create(flag: :ready_to_install)
  end

  def send_how_it_looks_email
    OrderMailer.how_does_it_look(customer.user.email, self).deliver
    self.order_notifications.create(flag: :how_it_looks)
  end

  def send_confirmation_email
    OrderMailer.thanks_for_order(customer.user.email, self).deliver
  end

  def send_dispatch_email
    OrderMailer.order_dispatched(customer.user.email, self).deliver
  end

  def send_admin_notification
    OrderMailer.new_order_notification(self).deliver
  end

  def discount_code
    discount.code unless discount.nil?
  end

  protected

  def set_expected_delivery_date
    delivery_duration = Settings.average_production_time.to_i + DELIVERY_DESTINATION[delivery_region]
    self.delivery_date = delivery_duration.business_days.from_now.to_date
  end

  def set_default_payment_status
    self.payment_status ||= PENDING
  end

  def set_default_status
    self.status ||= 'new'
  end

  def filtered_attributes(filter)
    result = {}
    filter.each{|k| result[k.to_sym] = self.send(k.to_sym) }
    result
  end

  def calculate_discount(subtotal)
    discount.present? ? discount.value_for(subtotal) : 0
  end

  def requires_card_validation
    !installation? && !!validate_payment_data
  end

end

class XpayPaymentStub
  def make_payment
    return 1
  end

  def response_block
    {
      error_code: 'Error message',
      transaction_reference: rand(999999)
    }
  end
end
