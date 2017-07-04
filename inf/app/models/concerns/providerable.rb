module Providerable
  extend ActiveSupport::Concern

  included do
    belongs_to :provider

    scope :facebook, -> { joins(:provider).where('providers.name': :facebook) }
    scope :twitter, -> { joins(:provider).where('providers.name': :twitter) }
    scope :google, -> { joins(:provider).where('providers.name': :google) }
    scope :linkedin, -> { joins(:provider).where('providers.name': :linkedin) }

    delegate :facebook?, :twitter?, :google?, :linkedin?, to: :provider
  end
end
