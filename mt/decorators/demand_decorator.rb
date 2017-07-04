class DemandDecorator < Draper::Decorator
  delegate_all

  def class_modificator
    enquiry = enquiries.first
    states = {
      'pending' => %w(pending proposed),
      'canceled' => %w(enquiry_cancelled enquiry_declined proposal_cancelled proposal_rejected)
    }
    states.each { |k, v| return k if v.include? enquiry.workflow_state } if enquiry.present?
    'accepted'
  end

  def purpose
    Demand::PURPOSE_TEXTS[object.purpose.try(:to_sym)]
  end

  def date
    # TODO: use proposal date if available
    return date_from.to_s(:long) if (date_to - date_from) < 1
    [date_from, date_to].map { |d| d.to_s(:compact) }.join(' - ')
  end

  def top_procedures
    # TODO: use proposal procedures if available
    procedures.pluck(:name).first(2).join('<br />').html_safe
  end

  def hospital_image_url
    enquiries.to_a.sample.hospital.image.url(:medium)
  end

  def thumb_class
    # TODO: add more cases
    modificator = case state
    when :pending
      :new
    when :proposed
      :awaiting
    when :proposal_accepted
      :accepted
    when :canceled
      :canceled
    when :payment_requested
      :awaiting
    when :paid
      :'payment-accepted'
    when :completed
      :accepted
    end

    "dashboard-thumb--#{modificator}"
  end
end
