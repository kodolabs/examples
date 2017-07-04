class Enquiry < ActiveRecord::Base
  include Workflow
  REVEAL_CONTACT_DETAILS_RATIO = 0.1

  CANCELED_REQUEST_STATES = %i(enquiry_cancelled enquiry_declined proposal_cancelled proposal_rejected).freeze
  REQUEST_STATES = %i(pending proposed proposal_accepted card_authorized).freeze

  UPCOMING_BOOKING_STATES = %i(payment_completed).freeze
  UNPAID_BOOKING_STATES = %i(card_authorized payment_requested).freeze
  CANCELED_BOOKING_STATES = %i(payment_cancelled).freeze
  BOOKING_STATES = UPCOMING_BOOKING_STATES + UNPAID_BOOKING_STATES

  belongs_to :demand
  belongs_to :hospital
  has_one :proposal, dependent: :destroy
  has_one :plus_payment, as: :payable, class_name: 'Payment'
  has_one :cancellation_fee
  has_many :payment_requests, dependent: :destroy
  has_many :payments, through: :payment_requests

  validates :demand_id, :hospital_id, presence: true
  validates :state_comment, presence: true, if: :enquiry_declined?

  after_commit :do_first_transition, on: :create
  after_commit :send_notification

  delegate :patient, to: :demand
  delegate :start_date, :price, :days_in_hospital, to: :proposal, prefix: true

  scope :archived, -> { where(archived: true) }
  scope :actual, -> { where(archived: false) }
  scope :ordered, -> { order(created_at: :desc) }

  class << self
    def requests(type = nil)
      case type
      when 'new'
        actual.where(workflow_state: REQUEST_STATES)
      when 'responded'
        archived.where(workflow_state: REQUEST_STATES)
      when 'canceled'
        actual.where(workflow_state: CANCELED_REQUEST_STATES)
      else
        where(workflow_state: REQUEST_STATES)
      end
    end

    def bookings(type = nil)
      case type
      when 'upcoming'
        actual.where(workflow_state: UPCOMING_BOOKING_STATES)
      when 'unpaid'
        actual.where(workflow_state: UNPAID_BOOKING_STATES)
      when 'completed'
        archived.where(workflow_state: BOOKING_STATES)
      when 'canceled'
        actual.where(workflow_state: CANCELED_BOOKING_STATES)
      else
        where(workflow_state: BOOKING_STATES)
      end
    end
  end

  workflow do
    state :created do
      event :first_transition, transitions_to: :preop
    end
    state :preop do
      on_entry { check_preop_existance }
      event :preop_created, transitions_to: :pending
    end
    state :pending do
      event :cancel_enquiry, transitions_to: :enquiry_cancelled
      event :decline_enquiry, transitions_to: :enquiry_declined
      event :make_proposal, transitions_to: :proposed
    end
    state :enquiry_cancelled
    state :enquiry_declined
    state :proposed do
      event :cancel_proposal, transitions_to: :proposal_cancelled
      event :reject_proposal, transitions_to: :proposal_rejected
      event :accept_proposal, transitions_to: :proposal_accepted
    end
    state :proposal_cancelled
    state :proposal_rejected
    state :proposal_accepted do
      on_entry { authorize_credit_card }
      event :authorize_card, transitions_to: :card_authorized
    end
    state :card_authorized do
      event :request_payment, transitions_to: :payment_requested
      event :cancel_payment, transitions_to: :payment_cancelled
    end
    state :payment_requested do
      event :cancel_payment, transitions_to: :payment_cancelled
      event :complete_payment, transitions_to: :payment_completed
    end
    state :payment_cancelled
    state :payment_completed do
      on_entry { check_outstanding_payment_requests }
      event :cancel_payment, transitions_to: :payment_cancelled
      event :request_payment, transitions_to: :payment_requested
      event :complete, transitions_to: :completed
    end
    state :completed
  end

  # patches default workflow method
  def persist_workflow_state(new_value)
    update_attributes(self.class.workflow_column => new_value)
  end

  def long_pending?
    pending? && (created_at < Time.now - 12.hours)
  end

  def public_id
    id + 100_000
  end

  def price_paid
    payments.sum(:price)
  end

  def price_owing
    proposal.price - price_paid
  end

  def price_requested
    payment_requests.sum(:price)
  end

  def price_can_be_requested
    proposal.price - price_requested
  end

  def charge_action
    update_attribute(:plus, true)
    EnquiryNotificationService.new(self, :plus_upgraded).send_email
  end

  def price
    Setting.plus_booking_price
  end

  def upgradable?
    hospital.plus_partner && !plus && actual?
  end

  def can_charge?(patient)
    upgradable? && self.patient == patient
  end

  def refundable?
    payment_cancelled?
  end

  def actual?
    archived == false && !payment_cancelled?
  end

  def param_event(string_caller)
    return unless string_caller.sub('!', '').to_sym.in?(current_state.events.keys)
    public_send(string_caller)
  end

  def all_payments
    [payments, plus_payment].flatten
  end

  def plus_booking?
    plus && actual?
  end

  def booking_cancel_available?
    actual? && current_state.events.keys.include?(:cancel_payment)
  end

  private

  # Workflow event side-effect methods
  def preop_created
    schedule_reminder(:pending)
  end

  def make_proposal
    schedule_reminder(:proposed)
  end

  def authorize_card
    schedule_reminder(:card_authorized)
  end

  def cancel_payment
    RefundsWorker.perform_async(id)
  end

  def complete_payment
    schedule_reminder(:payment_completed) if payment_requests.count == 1
    show_contact_details
  end

  def decline_enquiry(comment)
    update_attribute(:state_comment, comment)
    comment.present? # this value will be returned by decline_enquiry!
  end
  # Workflow event side-effect methods end

  def do_first_transition
    first_transition! if workflow_state == 'created'
  end

  def show_contact_details
    return false if price_paid < (proposal.price * REVEAL_CONTACT_DETAILS_RATIO).ceil
    update_column(:reveal_contact_details, true)
  end

  def authorize_credit_card
    authorize_card! if patient.credit_cards.any?
  end

  def check_outstanding_payment_requests
    request_payment! if payment_requests.without_payment.any?
  end

  def check_preop_existance
    preop_created! if demand.patient.preop_form
  end

  def send_notification
    return unless previous_changes[:workflow_state]
    EnquiryNotificationService.new(self).send_email
  end

  def schedule_reminder(action)
    ReminderService.new(action, self).schedule
  end
end
