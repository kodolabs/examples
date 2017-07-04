module ProfileBuilder
  class ValidateParams < Rectify::Command
    def initialize(form, param_names)
      @form = form
      @param_names = param_names
    end

    def call
      @form.validate
      return broadcast(:ok) if invalid_attributes.none?
      broadcast(:invalid, invalid_attributes)
    end

    private

    def invalid_attributes
      @invalid_attributes ||= @form.errors.to_h.with_indifferent_access.slice(*@param_names)
    end
  end
end
