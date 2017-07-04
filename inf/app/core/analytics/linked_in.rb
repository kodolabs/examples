class Analytics::LinkedIn < Analytics::Base
  TIME_OFFSET = 1.month.freeze

  def call
    request_updates_data
  end

  def chartjs_data
    @updates_data
  end

  def show_filter?
    account && pages_present?
  end

  def pages_collection
    pages.map { |page| [page.fetch('name'), page.fetch('id')] }
  end

  def page
    OpenStruct.new(selected_page)
  end

  private

  def request_updates_data
    timestamp_from = (DateTime.current - TIME_OFFSET).to_time.to_i
    @updates_data = api_service.updates_analytics(selected_page, timestamp_from)
  end

  def selected_page
    raise Linkedin::WrongPageException if page_from_params.nil?
    page_from_params
  end

  def page_from_params
    if @params[:page_id].blank?
      pages[0]
    else
      pages.find { |page| page.fetch('id') == @params[:page_id].to_i }
    end
  end

  def pages_present?
    pages_collection && !pages_collection.empty?
  rescue ::Linkedin::AuthException
    false
  end

  def pages
    @pages ||= pages_service.index
  end

  def account
    @accout ||= @customer.linkedin_account
  end

  def api_service
    @service ||= Linkedin::Analytics.new(account.token)
  end

  def pages_service
    @pages_service ||= Linkedin::Pages.new(account.token)
  end
end
