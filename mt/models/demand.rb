class Demand < ActiveRecord::Base
  PURPOSE_TEXTS = {
    booking: 'I am ready to make a booking',
    information: 'I am getting more information'
  }.freeze

  ACTIVE_REQUEST_STATES = %i(preop pending proposed proposal_accepted card_authorized).freeze
  CANCELED_REQUEST_STATES = %i(enquiry_declined enquiry_cancelled proposal_cancelled proposal_rejected).freeze
  REQUEST_STATES = ACTIVE_REQUEST_STATES + CANCELED_REQUEST_STATES

  UPCOMING_BOOKING_STATES = %i(card_authorized payment_requested payment_completed).freeze
  CANCELED_BOOKING_STATES = %i(payment_cancelled).freeze
  BOOKING_STATES = UPCOMING_BOOKING_STATES + CANCELED_BOOKING_STATES

  attr_accessor :hospital_id, :hospital_ids

  enum purpose: %i(booking information)

  belongs_to :patient
  has_many :enquiries, dependent: :destroy
  has_many :demand_procedures, dependent: :delete_all
  has_many :procedures, through: :demand_procedures

  accepts_nested_attributes_for :patient

  validates :purpose, presence: true
  validates :patient, :date_from, :date_to, presence: true
  validates :date_from, date: { after_or_equal_to: Date.today }
  validates :date_to, date: { after_or_equal_to: :date_from }

  scope :ordered, -> { order(created_at: :desc) }

  class << self
    def proposals(type = nil)
      demands_by_states case type
      when 'active'
        ACTIVE_REQUEST_STATES
      when 'canceled'
        CANCELED_REQUEST_STATES
      else
        REQUEST_STATES
      end
    end

    def bookings(type = nil)
      if type == 'completed'
        # TODO: `completed` workflow_state is ignored
        return demands_by_states(BOOKING_STATES, true)
      end

      demands_by_states case type
      when 'upcoming'
        UPCOMING_BOOKING_STATES
      when 'canceled'
        CANCELED_BOOKING_STATES
      else
        BOOKING_STATES
      end
    end

    private

    def demands_by_states(enquiry_states, archived = false)
      joins(:enquiries).where('enquiries.archived = ?', archived)
        .where('enquiries.workflow_state IN (?)', enquiry_states)
        .includes(:enquiries)
    end
  end

  def create_with_enquiries
    self.multiple_hospitals = true unless hospital_id.present?
    return unless save
    hospitals = hospital_id.present? ? [hospital_id] : hospital_ids.first.split
    hospitals.each { |id| enquiries.create(hospital_id: id) }
    send_notification
  end

  # TODO: move to decorator
  def procedures_list(add_dot = true)
    list = procedures.pluck(:name).join(', ')
    list += '.' if add_dot
    list
  end

  # TODO: test and refactor
  def state
    enquiry = enquiries.first
    return :completed if enquiry.archived

    single_enquiry_state = case enquiry.workflow_state.to_sym
    when :preop, :pending
      :pending
    when :proposed
      :proposed
    when :proposal_accepted, :card_authorized
      :proposal_accepted
    when :payment_requested
      :payment_requested
    when :payment_completed
      :paid
    when :payment_cancelled
      :canceled
    when :completed
      :completed
    when *Enquiry::CANCELED_REQUEST_STATES
      :canceled
    end

    return single_enquiry_state unless multiple_hospitals?
    return single_enquiry_state unless single_enquiry_state.in?(%i(pending proposed))
    TopHospitals.new(self).select.any? ? :proposed : :pending
  end

  def send_notification
    return true unless multiple_hospitals? && patient.preop_form.present?
    DemandNotificationService.new(self).send_email
  end

  def mark_as_pending
    enquiries.with_preop_state.each(&:preop_created!)
    send_notification
  end
end
