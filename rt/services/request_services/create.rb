module RequestServices
  class Create
    def initialize(params, customer, location_logo = nil)
      @params = params
      @customer = customer
      @location_logo = location_logo
    end

    def call
      prepare_params
      @request = RequestServices::Build.new(params).call
      extend(@request.sms? ? SmsContext : EmailContext)
      ActiveRecord::Base.transaction do
        create_new_template if need_create_template?
        @request.save
        raise ActiveRecord::Rollback unless @request.persisted?
        check_logo
        create_invitations
      end
      SendFeedbackRequestsWorker.perform_async(@request.id) if @request.persisted?
      @request
    end

    private

    attr_reader :params, :customer, :location_logo

    def check_logo
      @request.location.update(logo: location_logo) if location_logo
    end

    def prepare_params
      params[:customer_id] = customer.id unless params[:customer_id]
      params[:participants] = params[:participants].gsub(/\s+/, '').split(',').uniq if params[:participants]
    end

    def create_invitations
      @request.participants.each { |contact| @request.request_invitations.create contact: contact }
    end

    def email_template_params
      {
        subject: params[:subject],
        body_top: params[:body_top],
        body_bottom: params[:body_bottom],
        name: params[:new_template_name],
        request_type: @request.email_template.try(:request_type)
      }
    end

    def sms_template_params
      {
        body: params[:body],
        name: params[:new_template_name]
      }
    end

    def create_new_template
      template = create_template
      unless template.persisted?
        @request.validate
        @request.errors.add(:new_template_name, template.errors[:name].join(','))
        raise ActiveRecord::Rollback
      end
      @request.assign_attributes("#{@request.send_method}_template_id" => template.id)
    end

    def need_create_template?
      params[:save_as_new].to_i.positive?
    end
  end
end
