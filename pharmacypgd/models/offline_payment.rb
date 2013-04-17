require 'tableless'

class OfflinePayment < ActiveRecord::Base

  has_no_table

  #class_inheritable_accessor :columns
  #
  #def self.columns() @columns ||= []; end
  #
  #def self.column(name, sql_type = nil, default = nil, null = true)
  #  columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  #end

  column :reference_number, :string
  column :payment_method, :string
  column :amount, :decimal, :precision => 8, :scale => 2
  column :purchased_at, :date

  REFERENCE_NUMBER_FORMAT = /^(\d+)-(\d+)$/

  attr_accessor :purchaser, :credits

  validates :reference_number, :reference_number => true, :presence => true
  validates :payment_method, :presence => true
  validates :amount, :presence => true, :numericality => { :minimum => 0.1 }

  def self.factory(ref_num, params)
    @offline_payment = case
      when PharmacistOfflinePayment::match(ref_num) then PharmacistOfflinePayment.new params
      else OfflinePayment.new params
    end
  end

  def save
    return unless valid?
    return unless self.class.match(self.reference_number)
    reference = self.class.parse_reference_number(self.reference_number)

    purchase = build_purchase(reference)

    if purchase.save
      true
    else
      purchase.errors.each {|k, v| self.errors[k] << v }
      self.errors[:amount] << "expected value: #{purchase.total_amount}"
      false
    end
  end

  def build_purchase(reference)
    purchase = Purchase.new
    purchase.purchaser                  = Organisation.find_by_number(reference[:organisation])
    purchase.credits                    = reference[:credits]
    purchase.reference_number           = self.reference_number
    purchase.total_amount_confirmation  = self.amount
    purchase.payment_method             = self.payment_method
    purchase.purchased_at               = self.purchased_at
    purchase
  end

  def self.match(number)
    !number.match(self::REFERENCE_NUMBER_FORMAT).nil?
  end

  def self.parse_reference_number(value)
    return if value.blank?
    match = value.match(self::REFERENCE_NUMBER_FORMAT)
    {
      :organisation => match[1].to_s,
      :credits => match[2].to_i
    }
  end
end