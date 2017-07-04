module CustomersServices
  class Create
    include ServiceModules::CallCreateSubscription

    attr_accessor :customer

    def initialize(params, admin = nil, nonce = nil)
      @params = params
      @params[:created_by_id] = admin.id if admin
      @nonce = nonce
    end

    def call
      check_params_for_create
      ActiveRecord::Base.transaction do
        @customer = Customer.create(customer_params)
        if customer.persisted?
          if @nonce
            create_subscription
            CustomersServices::SaveCreditCard.new(@params, @customer).call
          end
          check_lead if customer.errors.empty? & customer.lead_id.present?
        end
      end
      CustomersServices::Invite.new(customer).call if customer.persisted? && customer.errors.empty? && !customer.demo?
      customer
    end

    private

    def check_params_for_create
      @params[:users_attributes]['0'][:skip_password_validation] = true
      @params[:subscription_attributes][:plan_id] = @params[:selected_plan_id] if @params[:subscription_attributes]
      @params[:validate_selected_plan] = true
    end

    def check_lead
      user = customer.primary_user
      Lead.where(id: customer.lead_id).update_all(user_id: user.id, status: Lead.statuses[:accepted])
    end

    def customer_params
      params = @params.dup
      params.delete :card
      params
    end
  end
end
