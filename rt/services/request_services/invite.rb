module RequestServices
  class Invite
    def initialize(request_id)
      @request = Request.find_by id: request_id
      extend(@request.sms? ? SmsContext : EmailContext) if @request
    end

    def call
      return false unless @request
      @request.request_invitations.each { |participant| send_to participant }
      send_copy if @request.send_copy?
      @request.update(sent_at: DateTime.now)
    end

    private

    def personalize_data(participant)
      RequestServices::Personalize.new(@request, participant).call
    end

    def send_to(participant)
      participant.update status: RequestInvitation::STATUS_SENT
    end
  end
end
