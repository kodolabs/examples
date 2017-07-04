require 'retriable'
module Shares
  class PostNotCreatedException < StandardError; end
  class AccountDisconnectedException < StandardError; end
  class PublishError < StandardError; end
  module Commands
    class Publish
      DELAY = 5
      include Rails.application.routes.url_helpers

      def initialize(share_id)
        @share = Share.find_by(id: share_id)
      end

      def call
        return if @share.blank? || @share.shareable.blank?
        @shareable = @share.shareable
        @share.publications.each do |p|
          begin
            raise AccountDisconnectedException if p.provider.nil?
            uid = publish(p)
            update_posts_with_retry(p, uid)
            raise PublishError if uid.blank?
            update_publication(p, uid)
            success_notify(p)
          rescue Koala::Facebook::ClientError => e
            p&.error!
            parsed_error = parsed_error_for(e)
            error_notify(p, error_message: parsed_error)
            next
          rescue AccountDisconnectedException, PublishError
            p&.error!
            error_notify(p)
            next
          rescue => e
            p&.error!
            raise_error(e) unless network_error?(e)
            auth_error?(e) ? show_banner(p) : error_notify(p)
          end
        end
      end

      private

      def publish(publication)
        provider = publication.provider.name
        publisher(provider).new(publication.owned_page).call(data(provider))
      end

      def publisher(provider)
        "Shares::Commands::Publish#{provider.capitalize}".constantize
      end

      def data(provider)
        decorator(provider).new(@shareable, quote: @share.message).call
      end

      def decorator(provider)
        "Shares::Decorators::#{@shareable.class.name.pluralize}::#{provider.camelize}".constantize
      end

      def update_publication(publication, uid)
        ::UpdatePublication.new(publication, @shareable, uid).call
      end

      def update_posts_with_retry(publication, uid)
        return update_posts(publication) unless publication.linkedin?

        Retriable.retriable on: PostNotCreatedException, tries: 10, base_interval: 10 do
          update_posts(publication)
          page = publication.owned_page.page
          published_post_id = page.posts.find_by(uid: uid).try(:id)
          raise ::Shares::PostNotCreatedException if published_post_id.blank?
        end
      end

      def update_posts(publication)
        RecentPostsWorker.new.perform(publication.owned_page.page_id)
      end

      def known_errors
        [
          'Koala::Facebook::ClientError',
          'Twitter::Error::Forbidden',
          'Linkedin::ApiException'
        ] + auth_errors
      end

      def auth_errors
        [
          'Twitter::Error::Unauthorized',
          'Koala::Facebook::AuthenticationError',
          'Account was disconnected',
          'Linkedin::AuthException'
        ]
      end

      def show_banner(publication)
        return if publication.account.blank?
        publication.account.disable!
        text = publication.account.decorate.banner
        notify(publication.customer,
          text: text,
          type: 'banner', error: true)
      end

      def raise_error(e)
        return if known_errors.include?(e.class.name)
        Rails.env.development? ? raise(e) : Rollbar.error(e)
      end

      def auth_error?(e)
        auth_errors.include?(e.class.name) ||
          auth_error_messages.any? { |m| e.message.include?(m) }
      end

      def auth_error_messages
        [
          "The user hasn't authorized the application"
        ]
      end

      def success_notify(publication)
        flash_notify(publication, type: :success)
      end

      def error_notify(publication, options = {})
        opts = options.merge(type: :error)
        flash_notify(publication, opts)
      end

      def flash_notify(publication, options)
        type = options[:type]
        title = publication.shareable.decorate.calendar_title
        html_title = ERB::Util.html_escape title
        provider = publication.owned_page.page.provider.name.capitalize
        is_error = type == :error
        error_message = options[:error_message]
        text = I18n.translate("notifications.#{type}", title: html_title, provider: provider)
        text += ". #{error_message}" if error_message.present?
        notify(@share.customer, text: text, type: 'flash', error: is_error, delay: DELAY)
      end

      def notify(customer, options)
        ::Notifications::Show.new(customer.id, options).call
      end

      def network_error?(e)
        [Faraday::TimeoutError, Faraday::ConnectionFailed].include?(e.class)
      end

      def parsed_error_for(e)
        error = JSON.parse(e.response_body).try(:[], 'error')
        code = error.try(:[], 'code')
        return I18n.t('shares.facebook.error.copyright') if code == 368
        error.try(:[], 'error_user_msg')
      rescue
        nil
      end
    end
  end
end
