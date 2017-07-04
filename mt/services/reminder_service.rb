class ReminderService
  JOB_NAMES = {
    pending: %i(manager_request),
    proposed: %i(patient_proposal),
    card_authorized: %i(manager_invoice),
    payment_completed: %i(patient_plus manager_booking),
    proposal_date_changed: %i(patient_plus manager_booking)
  }.freeze

  TIMEOUTS = {
    manager_request: 8.hours,
    patient_proposal: 12.hours,
    manager_invoice: 12.hours,
    patient_plus: 3.weeks,
    manager_booking: 1.week
  }.freeze

  def initialize(action, enquiry)
    @action = action
    @enquiry = enquiry
  end

  def schedule
    JOB_NAMES[@action].each do |name|
      schedule_options = schedule_time(name)
      next if incorrect?(schedule_options)
      job_class(name).set(schedule_options).perform_later(@enquiry.id)
    end
  end

  private

  def job_class(job_name)
    "#{job_name}_reminder_job".camelize.constantize
  end

  def schedule_time(job_name)
    timeout = TIMEOUTS[job_name]
    case job_name
    when :manager_request, :patient_proposal, :manager_invoice
      { wait: timeout }
    when :patient_plus, :manager_booking
      { wait_until: @enquiry.proposal.schedule_date(timeout).try(:to_time) }
    end
  end

  def incorrect?(schedule_options)
    nil.in? schedule_options.values
  end
end
