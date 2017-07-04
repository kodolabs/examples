module Domains
  class EditForm < Rectify::Form
    attribute :name, String
    attribute :network_id, Integer
    attribute :status, Integer
    attribute :source, Integer
    attribute :expires_at, Date
    attribute :dns_account_id, Integer
    attribute :hosting_expires_at, Date
    attribute :activated_at, Date
    attribute :name_servers, String

    validates :name, presence: true
    validate :check_name
    validate :uniq_name

    def check_name
      domain_name = ValidateHelper.parse_name(name)
      return if ValidateHelper.correct_name?(domain_name)
      errors.add(:name, I18n.t('notifications.invalid_domain', invalid_domain: domain_name))
    end

    def uniq_name
      domain_name = ValidateHelper.parse_name(name)
      return if unique_name?(domain_name)
      errors.add(:name, I18n.t('notifications.duplicate_domain', duplicate_domain: domain_name))
    end

    private

    def unique_name?(domain_name)
      domain = Domain.find_by(name: domain_name)
      return true if domain.blank?
      return true if domain.id == id
      false
    end
  end
end
