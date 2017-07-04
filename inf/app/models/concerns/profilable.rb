module Profilable
  extend ActiveSupport::Concern

  included do
    def form_params
      @form_params ||= JSON.parse(data).with_indifferent_access
    end

    def method_missing(m, *args)
      return super(*args) if args.present?
      form_params.try(:send, :[], m) || super
    end

    def respond_to_missing?(_m, _opts)
      super
    end

    def bulk_billing
      form_params['bulk_billing']
    end
  end
end
