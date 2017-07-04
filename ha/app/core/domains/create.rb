module Domains
  class Create < Rectify::Command
    def initialize(form)
      @form = form
    end

    def call
      return broadcast(:invalid) if @form.invalid?
      create_domains(@form)
      broadcast(:ok)
    end

    def create_domains(form)
      attributes = form.attributes.slice!(:domains)
      form.parsed_domains.each do |domain_name|
        CreateDomain.new(domain_name, attributes).call
      end
    end
  end
end
