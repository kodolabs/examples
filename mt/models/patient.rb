class Patient < ActiveRecord::Base
  acts_as_messageable

  belongs_to :user
  belongs_to :facilitator
  has_one :preop_form, dependent: :destroy
  has_many :credit_cards
  has_many :demands
  has_many :enquiries, through: :demands
  has_many :payment_requests, through: :enquiries
  has_many :payments, through: :payment_requests
  has_many :plus_payments, through: :enquiries
  has_many :cancellation_fees, through: :enquiries
  has_many :reviews, dependent: :destroy

  accepts_nested_attributes_for :user

  validates :first_name, :last_name, presence: true

  def email
    facilitated? ? facilitator.email : user.email
  end

  def enquiries_state_to_card_authorized
    enquiries.with_proposal_accepted_state.each(&:authorize_card!)
  end

  def default_card
    credit_cards.first
  end

  def birth_date
    dob = preop_form.try(:data).try(:[], :dob)
    return unless dob
    Date.strptime(dob, '%d/%m/%Y')
  end

  def age
    return 0 unless birth_date
    now = Date.today
    full_year = birth_date.change(year: now.year) < now
    now.year - birth_date.year - (full_year ? 0 : 1)
  end

  def mailboxer_name
    "#{first_name} #{last_name}"
  end
  alias name mailboxer_name

  def mailboxer_email(object)
    return nil if object.sender == self
    email
  end

  def mark_enquiries_as_pending
    preop_demands = demands.where(id: enquiries.with_preop_state.select(:demand_id))
    preop_demands.each(&:mark_as_pending)
  end

  def enquiries_for_review
    enquiries.archived.bookings.where.not(id: reviews.select(:enquiry_id))
      .joins(:proposal).includes(:hospital, proposal: [:procedures])
      .order('proposals.start_date')
  end

  def public_id
    id + 10_000
  end

  def facilitated?
    facilitator.present?
  end

  def requests_count
    demands.proposals.count
  end

  def bookings_count
    demands.bookings.count
  end
end
