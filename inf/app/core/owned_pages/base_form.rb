module OwnedPages
  class BaseForm < Rectify::Form
    attribute :pages
    attribute :account

    def initialize(account, api_pages)
      @account = account
      @api_pages = api_pages
    end

    def pages
      return [] if @api_pages.blank?
      @pages ||= decorate
    end

    def owned_pages
      @owned_pages ||= @account.owned_pages.includes(:page).order('pages.title')
    end

    def decorate
      pages = mark_connected
      pages.sort_by { |_k, v| v }
    end
  end
end
