# This form used only on initial GET request

module OwnedPages
  class FacebookForm < ::OwnedPages::BaseForm
    def mark_connected
      @api_pages.map do |api_page|
        page = connected_page_for(api_page)
        api_page['picture'] = picture_for(api_page)
        api_page['record_id'] = page.id if page
        api_page['checked'] = 1 if page
        api_page
      end
    end

    def connected_page_for(api_page)
      owned_pages.find do |owned_page|
        if owned_page.page.uid
          api_page['id'] == owned_page.page.uid
        else
          api_page['username'] == owned_page.page.handle
        end
      end
    end

    def picture_for(api_page)
      api_page.try(:[], 'picture').try(:[], 'data').try(:[], 'url')
    end
  end
end
