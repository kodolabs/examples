module Customers
  class Form < Rectify::Form
    mimic :form

    attribute :customer
    attribute :action
    attribute :full_name, String
    attribute :phone, String
    required_attributes = %i(
      full_name phone
    )
    attribute :demo

    validates(*required_attributes, presence: true)
    validates :phone,
      phony_plausible: true,
      format: { with: /\A\+\d+/, message: 'invalid number' }

    def full_name
      is_edit ? profile&.full_name : super
    end

    def demo
      is_edit ? customer&.demo : super
    end

    def profile_model_attributes
      attributes.slice(:full_name, :phone)
    end

    def model_attributes
      attributes.slice(:demo)
    end

    def phone
      value = is_edit ? profile&.phone : super
      return if value.blank?
      PhonyRails.normalize_number(value)
    end

    def phone_formatted
      return nil if phone.blank?
      phone.phony_formatted(format: :international, spaces: ' ')
    end

    private

    def profile
      @profile ||= customer.primary_user.profile
    end

    def is_edit
      action == 'edit'
    end
  end
end
