module Profiles
  class Update < Rectify::Command
    def initialize(form, event)
      @form = form
      @event = event
    end

    def call
      return broadcast(:invalid_form) if @form.invalid?
      profile = update_profile(@form)
      return broadcast(:invalid, @event) unless profile
      broadcast(:ok, @event)
    end

    private

    def update_profile(form)
      Profile.find(form.id).update(form.attributes)
    end
  end
end
