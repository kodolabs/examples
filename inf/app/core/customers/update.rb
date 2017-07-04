module Customers
  class Update < Rectify::Command
    def initialize(form)
      @form = form
      @customer = @form.customer
      @profile = @customer.primary_user.profile
    end

    def call
      return broadcast(:invalid) if @form.invalid?
      return broadcast(:invalid) unless update_success
      broadcast(:ok)
    end

    private

    def update_success
      transaction do
        @profile.update!(@form.profile_model_attributes)
        @customer.update!(@form.model_attributes)
        @customer.generate_demo_token
      end
    end
  end
end
