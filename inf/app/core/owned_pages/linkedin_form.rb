# This form used only on initial GET request

module OwnedPages
  class LinkedinForm < ::OwnedPages::BaseForm
    def mark_connected
      @api_pages.map do |api_page|
        page = connected_page_for(api_page)
        api_page['uid'] = api_page['id']
        api_page['record_id'] = page.id if page
        api_page['checked'] = 1 if page
        api_page
      end
    end

    def connected_page_for(api_page)
      owned_pages.find { |owned_page| api_page['id'].to_s == owned_page.page.uid }
    end

    def owned_pages
      @owned_pages ||= @account.owned_pages.includes(:page).order('pages.title')
    end
  end
end
