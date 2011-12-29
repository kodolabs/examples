require "google4r/checkout"
require 'cgi'
require 'pdf_forms'

class Purchase < ActiveRecord::Base

  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper

  REFERENCE_FORMATS = [/^(\d+)-(\d+)$/, /^(\d+)-(\d+)-(\d+)$/]
  ORGANISATION_PAYMENT_METHODS = {
    'cheque'  => 'Post cheque',
    'wire'    => 'Bank transfer',
    'moto'    => 'MOTO',
    'card'    => 'Debit/credit card'
  }

  PHARMACIST_PAYMENT_METHODS = {
    'credit'  => 'Organisation credit',
    'cheque'  => 'Post cheque',
    'wire'    => 'Bank transfer',
    'card'    => 'Debit/credit card'
  }

  belongs_to  :purchaser, :polymorphic => true
  has_one :invoice, :as => :invoicable, :dependent => :destroy

  has_one     :payment

  validates   :credits, :numericality => { :only_integer => true, :minimum => 1 }, :presence => true
  validates   :payment_method, :presence => true
  validates   :purchased_at, :presence => true
  validates   :purchaser, :associated => true

  validates :total_amount, :amount_confirmation => { :message => "does not match paid amount" }, :if => lambda { |e| e.reference_number.present? }

  default_scope order("created_at DESC")
  scope :with_invoice, joins(:invoice)
  scope :not_free, where('payment_method != "free"')
  scope :by_purchaser_name, lambda {|name| joins("left join users on (users.id = purchases.purchaser_id) and (purchases.purchaser_type = 'User')").joins("left join organisations on (organisations.id = purchases.purchaser_id) and (purchases.purchaser_type = 'Organisation')").where(['users.name like :name or organisations.name like :name', {:name => "%#{name}%"}])}

  before_validation :set_purchased_at
  before_validation :calculate_order_amount
  after_create      :add_purchaser_credits
  before_destroy    :remove_purchaser_credits

  def calculate_order_amount
    if self.credits.blank? || self.credits == 0
      self.total_amount = 0
      self.amount = 0
    else
      price = Price.find_price_for(self.credits.abs)
      self.amount = price * self.credits
      self.total_amount = with_vat(with_discount(self.amount)).round(2)
    end

    self.total_amount
  end

  def adjust_purchaser_credits(credits)
    if self.purchaser.respond_to? :credits
      self.purchaser.add_credits(credits)
    end
  end

  def add_purchaser_credits
    adjust_purchaser_credits(self.credits)
  end

  def remove_purchaser_credits
    adjust_purchaser_credits(-self.credits)
  end

  def with_vat(amount)
    self.vat = Purchase::get_vat
    amount.coefficient(self.vat)
  end

  def with_discount(amount)
    self.discount = get_discount unless self.discount.present? && self.discount > 0
    if self.discount > 0
      amount.coefficient(-self.discount)
    else
      amount
    end
  end

  def self.get_vat
    AppConfig['vat'].to_f
  end

  def vat_amount
    self.vat ||= self.class.get_vat
    ((amount - discount_amount) / 100.0) * self.vat
  end

  def get_discount
    return 0 if self.purchaser.blank? || self.purchaser.discount.blank?
    self.purchaser.discount
  end

  def discount_amount negative = false
    result = (amount / 100.0) * get_discount
    result *= -1 if negative
    result
  end

  def unit_price
    return 0 if self.credits.blank? || self.amount.blank?
    self.amount / self.credits
  end

  def unit_price_in_pennies(include_vat = false)
    return 0 if self.credits.blank? || self.amount.blank?
    price = with_discount(self.amount) / self.credits
    price *= (1 + self.vat / 100.0) if !!include_vat
    (price * 100.0).round
  end

  def set_purchased_at
    self.purchased_at ||= Date.today
  end

  def adjustment?
    payment_method == 'adjustment'
  end

  def payment_method_string
    Purchase::ORGANISATION_PAYMENT_METHODS[self.payment_method] || self.payment_method.capitalize
  end

  def self.organisation_payment_methods
    @methods = Purchase::ORGANISATION_PAYMENT_METHODS
    @methods.delete 'moto'
    @methods
  end

  def self.pharmacist_payment_methods
    Purchase::PHARMACIST_PAYMENT_METHODS
  end

  def self.admin_payment_methods
    @methods = Purchase::ORGANISATION_PAYMENT_METHODS
    @methods.delete 'card'
    @methods
  end

  def google_checkout_button(ref_number, redirect_to = '')

    checkout_command = GoogleCheckoutBuilder.checkout
    checkout_command.continue_shopping_url = redirect_to.escape_xml unless redirect_to.blank?

    # Adding an item to shopping cart
    checkout_command.shopping_cart.create_item do |item|
      if self.purchaser.is_a? Organisation
        item.name         = "#{AppConfig['app_name']} - Organisation Credits"
        item.description  = "PGD rights credits for use by your Pharmacists"
      elsif self.purchaser.is_a? User
        item.name         = "#{self.payment.pgd.name} PGD rights"
        item.description  = "Annual PGD rights in #{self.payment.organisation.name}"
      end

      item.unit_price   = Money.new(self.unit_price_in_pennies, "GBP")
      item.quantity     = self.credits
    end

    checkout_command.shopping_cart.private_data = { :reference_number => ref_number }
    checkout = checkout_command.send_to_google_checkout

    link_to image_tag(GoogleCheckoutConfig['google_checkout_button']), checkout.redirect_url
  end

  def subtotal
    amount
  end

  def total
    total_amount
  end

  def title
    if purchaser.is_a? Organisation
      "#{AppConfig['app_name']} - Organisation Credits"
    elsif purchaser.is_a? User
      "#{payment.pgd.name} PGD rights"
    end
  end

  def description
    if purchaser.is_a? Organisation
      "PGD rights credits for use by your Pharmacists"
    elsif purchaser.is_a? User
      "Annual PGD rights in #{payment.organisation.name}"
    end
  end

  def create_invoice
    invoice = Invoice.create(
        :subtotal           => self.subtotal,
        :vat                => self.vat,
        :total              => self.total,
        :payment_reference  => self.reference_number)

    invoice.invoice_items << InvoiceItem.new(:title => title, :description => description, :price => self.unit_price, :quantity => self.credits)

    self.invoice = invoice
    self.invoice.update_attribute(:to, self.invoice.invoice_to)
  end

  def pdf(organisation, pgd_name = '')
    dir = "#{Rails.root}/public/purchases/"
    Dir.mkdir(dir) unless File.directory?(dir)

    pdf_file = "#{dir}#{self.reference_number}.pdf"

    PdfForms::PdftkWrapper.new('/usr/bin/pdftk').fill_form "#{Rails.root}/forms/#{self.payment_method}.pdf", pdf_file,
      :reference    => self.reference_number,
      :item         => self.purchaser.is_a?(Organisation) ? "#{self.credits} PGD rights credit#{(self.credits > 1)?'s':''}" : "#{pgd_name} PGD rights",
      :cost         => self.total_amount,
      :number       => organisation.number

    pdf_file if File.exists?(pdf_file)
  end

end

class String
  def escape_xml
    self.
      gsub(%r{&}, '&amp;').
      gsub(%r{<}, '&lt;').
      gsub(%r{>}, '&gt;')
  end
end

class BigDecimal
  def coefficient(coef)
    (self * (1 + coef / 100.0)).round(2)
  end
end

class Float
  def coefficient(coef)
    (self * (1 + coef / 100.0)).round(2)
  end
end