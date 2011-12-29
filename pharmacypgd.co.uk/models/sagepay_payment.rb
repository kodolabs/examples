require "awesome_print"

class SagepayPayment < ActiveRecord::Base

  belongs_to :user
  has_many :sagepay_transactions

  attr_accessor :response, :source

  state_machine :status, :initial => :new do

    after_transition :on => :payment, :do => :process_payment

    event :register do
      transition :new => :registered
    end

    event :payment do
      transition :registered => :complete
    end

    event :fail do
      transition :registered => :failed
    end
  end

  def pay
    registration(:payment)
  end

  def set_status(new_status)
    case new_status
      when :ok
        payment!
      when :rejected
        reject!
    end
  end

protected

  def registration(tx_type)
    if complete? || registered?
      raise RuntimeError, "Sage Pay transaction has already been registered for this payment!"
    end

    sage_pay_registration = SagePay::Server.registration(
      :tx_type          => tx_type,
      :vendor_tx_code   => vendor_tx_code.to_s,
      :description      => description,
      :currency         => currency,
      :amount           => amount,
      :billing_address  => sagepay_address,
      :notification_url => AppConfig['secure_app_url'] + '/sagepay_notifications'
    )

    begin
      self.response = sage_pay_registration.run!
    rescue ArgumentError => e
      error_message = sage_pay_registration.errors.full_messages.join ', '
      raise RuntimeError, e.to_s + ' ' + error_message
    end


    if response.nil?
      error_message = sage_pay_registration.errors.full_messages.join ', '
      logger.error "  ERROR: #{error_message}"
      raise RuntimeError, error_message
    end

    if response.ok?

      logger.info "  #{vendor_tx_code} - SUCCESSFUL REGISTRATION"

      self.register!

      sagepay_transactions.create!(
        :vendor                   => sage_pay_registration.vendor,
        :transaction_type         => sage_pay_registration.tx_type.to_s,
        :transaction_code         => sage_pay_registration.vendor_tx_code,
        :security_key             => response.security_key,
        :sagepay_transaction_code => response.vps_tx_id
      )

      response.next_url
    else
      logger.error 'SagePay response - ' + response.status_detail
      raise RuntimeError, 'SagePay response - ' + response.status_detail
    end
  end

  def process_payment
    puts " ------ processing payment data ------ "

    if vendor_tx_code =~ /PO-\d+-\d+/
      process_order_payment
    else
      process_purchase_payment
    end
  end

  def process_order_payment
    order = Order.find_by_reference_number vendor_tx_code
    unless order.blank?

      if order.confirm(amount)
        order.save
        true
      else
        false
      end
    else
      raise 'Order not found. Reference=' + vendor_tx_code
    end
  end

  def process_purchase_payment
    reference_number = vendor_tx_code.match(/^.+_(.+)$/).try(:[], 1)

    offline_payment_params = {
      :reference_number => reference_number,
      :payment_method   => 'card',
      :amount           => amount,
      :purchased_at     => Date.today
    }

    offline_payment = OfflinePayment.factory(reference_number, offline_payment_params)
    if offline_payment.save
      true
    else
      message = 'Errors: ' + offline_payment.errors.full_messages.join(", ")
      Rails.logger.error message
      raise message
    end
  end

  def logger
    @logger ||= Logger.new(File.open(Rails.root.join('log', 'sagepay.log'), 'a'))
  end

  def sagepay_address
    SagePay::Server::Address.new(
      :first_names => user.first_name[0..19],
      :surname     => user.last_name[0..19],
      :address_1   => user.street_address,
#      :address_2   => address_2,
      :city        => user.city,
      :post_code   => user.postcode,
      :state       => '',
      :phone       => user.telephone_1,
      :country     => 'GB'
    )
  end
end
