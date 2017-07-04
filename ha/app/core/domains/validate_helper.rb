module Domains
  class ValidateHelper
    def self.correct_name?(domain_name)
      PublicSuffix.valid?(domain_name)
    end

    def self.parse_name(domain_name)
      domain_name.gsub(/[[:space:]]/, '').gsub('www.', '')
    end
  end
end
