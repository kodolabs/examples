module ProfileBuilder
  class Sync < Rectify::Command
    attr_reader :form, :customer

    def initialize(form, customer, user)
      @form = form
      @customer = customer
      @user = user
    end

    def call
      return broadcast(:invalid, form.errors) if form.invalid?
      return broadcast(:error) unless save
      spread_data
      set_trial
      broadcast(:ok)
    end

    private

    def save
      @profile = Profile.find_or_initialize_by(user: @user)
      @profile.update_attribute(:data, @form.model_data_attributes)
    end

    def spread_data
      ProfileBuilder::Spread.call(@profile, @customer, @user)
    end

    def set_trial
      @customer.update_column(
        :trial_ends_on,
        Date.current + Setting['general.trial_length_days'].to_f.days
      )
    end
  end
end
