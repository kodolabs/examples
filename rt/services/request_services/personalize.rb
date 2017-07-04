module RequestServices
  class Personalize
    def initialize(request, request_invitation = nil, preview: false)
      @request = request.decorate
      @request_invitation = request_invitation&.decorate
      @preview = preview
      extend(@request.sms? ? SmsContext : EmailContext)
    end

    def call
      personalize_params
    end

    private

    def personalize(string)
      string.gsub!(/%FEEDBACK_LINK%/, request_invitation.invite_link(preview: preview?, sms: request.sms?)) if request_invitation
      string
        .gsub(/%USER_NAME%/, request.customer&.business_name.to_s)
        .gsub(/%LOCATION_NAME%/, request.location_name.to_s)
        .gsub(/%REVIEW_SITES%/, request.review_sites(preview: preview?, sms: request.sms?).to_s)
    end

    attr_reader :request, :request_invitation

    def preview?
      @preview
    end
  end
end
