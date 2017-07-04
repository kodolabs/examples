module Domains
  class DomainForm < Rectify::Form
    require 'uri'
    attribute :domains, String
    attribute :network_id, Integer
    attribute :source, Integer

    validates :domains, presence: true
    validate :check_names

    def check_names
      @invalid_domains = []
      parsed_domains.each do |domain_name|
        @invalid_domains << domain_name unless ValidateHelper.correct_name?(domain_name)
      end
      return if duplicate_domains.blank? && @invalid_domains.blank?
      invalid_domains_error if @invalid_domains.present?
      duplicate_domains_error if duplicate_domains.present?
    end

    def parsed_domains
      @parsed_domains ||= domains.split(/\r\n/).reject(&:blank?).map do |domain|
        ValidateHelper.parse_name(domain)
      end.uniq
    end

    private

    def duplicate_domains
      @duplicate_domains ||= Domain.where('name IN (?)', @parsed_domains).pluck(:name)
    end

    def invalid_domains_error
      errors.add(:domains,
        I18n.t('notifications.invalid_domains', invalid_domains: @invalid_domains.join(', ')))
    end

    def duplicate_domains_error
      errors.add(:domains,
        I18n.t('notifications.duplicate_domains', duplicate_domains: duplicate_domains.join(', ')))
    end
  end
end
