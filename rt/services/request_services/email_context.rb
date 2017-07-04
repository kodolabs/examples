module RequestServices
  module EmailContext
    def send_to(participant)
      @request.send_method = :email
      email_data = personalize_data(participant)
      @request.send_method = :sms
      text_data = personalize_data(participant)
      FeedbackRequestEmails.invite(email_data, text_data, @request.location_id).deliver_later
      super
    end

    def personalize_params
      {
        body: personalize(request.object.body).strip,
        from: "\"#{request.sender_name}\" <#{request.sender_email}>",
        subject: personalize(request.subject&.strip),
        to: @request_invitation&.contact,
        content_type: 'text/html'
      }
    end

    def create_template
      EmailTemplate.create email_template_params.merge(customer: customer)
    end

    def send_copy
      @request.send_method = :email
      invite = @request.request_invitations.build(contact: @request.customer.primary_email)
      personalized_data = RequestServices::Personalize.new(@request,invite).call

      @request.send_method = :sms
      text_data = RequestServices::Personalize.new(@request,invite).call

      FeedbackRequestEmails.invite(personalized_data, text_data, @request.location_id).deliver_now
    end
  end
end
