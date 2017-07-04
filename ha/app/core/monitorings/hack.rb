module Monitorings
  class Hack < Monitorings::Base
    STOP_KEYWORDS = ['public_html'].freeze
    ALLOWED_HTTP_CODES = 200..226

    private

    def can_check?
      (domain.success? || domain.uptime_unknown?) && !domain.inactive?
    end

    def find_result
      @response = RestClient.get(@domain.name)
      @http_code = @response&.code
      raise StandardError, @error_message unless response_valid?
      { status: :success, http_code: @http_code }
    rescue => e
      { status: :error, error_message: e.message }
    end

    def save_current_status
      @current_hack_status = @domain.hack_status.to_sym
    end

    def hack_status_not_change?
      @current_hack_status == @domain.hack_status.to_sym
    end

    def track_status_change
      return if data[:status] == :error
      return if hack_status_not_change?
      Domains::TrackHackStatusChange.call(domain: @domain) if @domain.hacked?
    end

    def domain_params
      { hack_status: data[:status] == :success ? :good : :hacked }
    end

    def response_valid?
      return false if invalid_http_code? || invalid_page_content_length?
      return false if not_contain_any_html? || contains_stop_keyword?
      true
    end

    def doc
      @doc ||= Nokogiri::HTML(@response&.body)
    end

    def invalid_http_code?
      return false if ALLOWED_HTTP_CODES.include?(@http_code)
      @error_message = I18n.t('notifications.invalid_http_code', code: @http_code)
      true
    end

    def invalid_page_content_length?
      content = doc.at_css('body')&.children&.to_html
      return false if content.present? && content&.size.to_i >= 1000
      @error_message = I18n.t('notifications.invalid_content_length', size: content&.size.to_i)
      true
    end

    def not_contain_any_html?
      stripted = ActionController::Base.helpers.strip_tags(@response&.body.to_s)
      return false if stripted.size != @response&.body&.size.to_i
      @error_message = I18n.t('notifications.not_contain_any_html')
      true
    end

    def contains_stop_keyword?
      content = doc.at_css('body')&.children&.to_html
      STOP_KEYWORDS.map do |keyword|
        next if content&.index(keyword).blank?
        @error_message = I18n.t('notifications.contain_stop_keyword', keyword: keyword)
      end.compact.any?
    end
  end
end
