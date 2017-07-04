module CustomersServices
  class Update
    include ServiceModules::CallCreateSubscription

    attr_accessor :customer

    def initialize(customer, params, nonce = nil, can_change_email: false)
      @customer = customer
      @params = params
      @was_demo = customer.demo?
      @change_plan = params[:selected_plan_id] && params[:selected_plan_id] != '' && params[:selected_plan_id].to_i != @customer.subscription.plan_id ? params[:selected_plan_id].to_i : false
      @nonce = nonce
      @can_change_email = can_change_email
    end

    def call
      check_params
      ActiveRecord::Base.transaction do
        if customer.update customer_params
          try_update_user if @can_change_email
          if @nonce
            create_subscription
            CustomersServices::SaveCreditCard.new(@params, @customer).call
          end

          if @was_demo && !customer.demo?
            CustomersServices::Invite.new(customer).call
            CustomersServices::StatusUpdate.new(customer, 'active').call if customer.suspended?
          end

          if @new_primary_user
            customer.users.where(primary: true).update_all(primary: false)
            customer.users.where(id: @new_primary_user).update_all(primary: true)
          end

          SubscriptionServices::Update.new(@customer, @customer.subscription, Plan.find(@change_plan)).perform if @change_plan
        end
      end
      customer
    end

    private

    def check_params
      if @change_plan && !@customer.payment_info?
        @params[:subscription_attributes][:plan_id] = @params[:selected_plan_id] if @params[:subscription_attributes]
        @change_plan = false
      end
      return if @params[:primary_user_id].blank? || customer.primary_user.id == @params[:primary_user_id].to_i
      @new_primary_user = @params[:primary_user_id].to_i
      @params.delete :primary_user_id
    end

    def try_update_user
      user_params = @params.dig(:users_attributes, '0')
      return unless user_params

      user_params.delete :id

      user = @customer.primary_user
      user.skip_reconfirmation!
      user.assign_attributes user_params
      user.save!
    end

    def customer_params
      params = @params.deep_dup
      params.delete :card
      params
    end
  end
end
