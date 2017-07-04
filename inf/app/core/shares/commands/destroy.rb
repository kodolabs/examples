module Shares
  module Commands
    class Destroy
      DELAY = 5
      def initialize(share_id)
        @share = Share.unscoped.find_by(id: share_id)
      end

      def call
        return if @share.blank?

        @skip_notify = skip_notify?
        @customer_id = @share.customer.id

        destroy_all
        notify
      end

      private

      def destroy_all
        %i(job campaigns published_posts shareable share).map do |obj|
          send("destroy_#{obj}")
        end
      end

      def notify
        return if @skip_notify
        options = {
          text: I18n.t('user.articles.shares.delete_linkedin'),
          type: :flash,
          error: true,
          delay: DELAY
        }
        ::Notifications::Show.new(@customer_id, options).call
      end

      def destroy_job
        Sidekiq::ScheduledSet.new.find_job(@share.job_id).try(:delete)
      end

      def destroy_campaigns
        @share.campaigns.each do |campaign|
          Campaigns::Delete.call(campaign)
        end
      end

      def destroy_published_posts
        @share.publications.each do |publication|
          next if publication.published_post.blank?
          next if publication.account.blank? || publication.try(:linkedin?)
          "Shares::Commands::Destroy_#{publication.provider.name}"
            .camelize.constantize.new(publication).call
          publication.published_post.destroy
        end
      end

      def destroy_shareable
        return unless @share.shareable.is_a?(Article)
        @share.shareable.destroy
      end

      def destroy_share
        @share.destroy unless @share.destroyed?
      end

      def skip_notify?
        @no_linked = @share.owned_pages.linked_in.blank?
        @skip_notify ||= @no_linkedin || @share.in_future?
      end
    end
  end
end
