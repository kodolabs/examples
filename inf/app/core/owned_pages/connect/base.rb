require 'errors/accounts_limit_reached_exception'

module OwnedPages
  module Connect
    class AccountPageDisconnected < StandardError; end
    class Base < Rectify::Command
      def initialize(form, customer)
        @form = form
        @customer = customer
        @account = @form.account
        @provider = @form.account.provider
      end

      def disconnect
        page_ids = @form.unchecked_pages.map { |p| page_for(p) }.compact
        return if page_ids.blank?
        @pages_for_disconnect = @customer.owned_pages.where(id: page_ids)

        is_disconnected = @pages_for_disconnect.any?
        return unless is_disconnected
        @pages_for_disconnect.update(account_id: nil)
        raise AccountPageDisconnected
      end

      def invalid_account?
        @account.active.blank?
      end

      def raise_error(error)
        Rails.env == 'development' ? raise(error) : Rollbar.error(error)
      end

      def connect_owned_page(page, token)
        OwnedPage.transaction do
          owned_page = OwnedPage.find_or_create_by(page_id: page.id)
          owned_page.account_id = @account.id
          owned_page.token = token
          owned_page.save if owned_page.changed?
          owned_page
        end
      end

      def page_for(p)
        return OwnedPage.find_by(id: p['record_id'])&.id if p['record_id'].present?
        # TODO: send record_id
        if p['handle'].present?
          page_by_handle = Page.find_by(handle: p['handle'])
          return page_by_handle.owned_pages.where(account_id: @account.id)&.first&.id
        end
        Page.find_by(uid: p['uid'])&.owned_pages&.where(account_id: @account.id)&.first&.id
      rescue
        nil
      end
    end
  end
end
