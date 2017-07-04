module Monitorings
  class Index < Monitorings::Base
    attr_accessor :response

    private

    def find_result
      response = Proxy::Search.new(domain).call
      raise StandardError, response[:error_message] if response[:error_message]
      doc = Nokogiri::HTML(response[:content])
      if doc&.at('p:contains("did not match any documents")').present?
        index_status = :not_indexed
      else
        pages = doc.search('div#resultStats')&.first&.content&.gsub(/\D/, '')
        index_status = pages.to_i.zero? ? :not_indexed : :indexed
      end
      { status: :success, index_status: index_status, pages_count: pages.to_i }
    rescue => e
      { status: :error, error_message: e.message }
    end

    def save_current_status
      @current_index_status = @domain.index_status.to_sym
    end

    def index_status_not_change?
      @current_index_status == @domain.index_status.to_sym
    end

    def track_status_change
      return if data[:status] == :error
      return if index_status_not_change?
      Domains::TrackIndexStatusChange.call(
        domain: @domain,
        blog: @domain.blog,
        old_status: @current_index_status,
        new_status: @domain.index_status.to_sym
      )
    end

    def domain_params
      return {} if data[:status] == :error
      {
        index_status: data[:index_status],
        index_pages: data[:pages_count]
      }
    end

    def monitoring_params
      return {} if data[:status] == :error
      super
    end

    def last_status_changed?
      return true if @monitoring.last_status_changed_at.nil?
      data[:index_status]&.to_s != @domain.index_status
    end
  end
end
