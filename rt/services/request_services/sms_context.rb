module RequestServices
  module SmsContext
    def send_to(participant)
      SmsService.send_later(personalize_data(participant))
      super
    end

    def personalize_params
      {
        number: request_invitation.contact,
        message: personalize(request.object.body)
      }
    end

    def create_template
      SmsTemplate.create sms_template_params.merge(customer: customer)
    end

    def send_copy
      personalized_data = RequestServices::Personalize.new(
        @request,
        @request.request_invitations.build(contact: @request.customer&.primary_user&.phone)
      ).call
      SmsService.send_later(personalized_data)
    end
  end
end
