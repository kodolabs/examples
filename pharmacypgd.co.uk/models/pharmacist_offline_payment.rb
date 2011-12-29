class PharmacistOfflinePayment < OfflinePayment

  REFERENCE_NUMBER_FORMAT = /^(\d+)-(\d+)-(\d+)$/

  def save
    return unless valid?
    return unless self.class.match(self.reference_number)
    reference = self.class.parse_reference_number(self.reference_number)

    payment = build_payment(reference)
    payment.purchase = build_purchase(reference)

    if payment.save
      true
    else
      payment.errors.each {|k, v| self.errors[k] << v }
      self.errors[:amount] << "expected value: #{payment.purchase.total_amount}"
      false
    end
  end

  def build_purchase(reference)
    purchase = Purchase.new
    #    purchase.purchaser        = User.find(reference[:user])
    purchase.credits                    = reference[:credits]
    purchase.reference_number           = self.reference_number
    purchase.total_amount_confirmation  = self.amount
    purchase.payment_method             = self.payment_method
    purchase.purchased_at               = self.purchased_at
    purchase
  end

  def build_payment(reference)
    payment = Payment.new
    payment.organisation  = Organisation.find_by_number(reference[:organisation])
    payment.user          = User.find_by_id(reference[:user])
    payment.pgd           = Pgd.for(payment.user).find_by_id(reference[:pgd])
    payment
  end

  def self.parse_reference_number(value)

    return if value.blank?
    match = value.match(REFERENCE_NUMBER_FORMAT)

    {
      :organisation => match[1].to_s,
      :user => match[2].to_i,
      :pgd => match[3].to_i,
      :credits => 1
    }
  end

  def self.model_name
    name = "offline_payment"
    name.instance_eval do
      def plural;   pluralize;   end
      def singular; singularize; end
      def human;    singularize; end # only for Rails 3
      def i18n_key; singularize; end # only for Rails 3
    end
    return name
  end

end