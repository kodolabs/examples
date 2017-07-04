module Articles
  class ScheduledPosts < Rectify::Query
    def initialize(current_customer)
      @current_customer = current_customer
    end

    def query
      @current_customer.shares
        .includes(:owned_pages, :campaigns, :shareable, publications: { owned_page: { page: [:provider] } })
        .select { |share| share.shareable.present? }.map do |share|
        statuses = share.publications.pluck(:status)
        {
          id: share.shareable_id,
          title: share.shareable.decorate.calendar_title,
          providers: share.owned_pages.connected.map { |p| p.page.provider.name }.uniq,
          in_future: share.in_future?,
          start: (share.scheduled_at || share.updated_at).try(:strftime, '%d/%m/%Y %H:%M'),
          has_campaign: share.campaigns.any?,
          shareable_type: share.shareable_type,
          share_id: share.id,
          is_pending: statuses.include?('pending'),
          is_error: statuses.include?('error')
        }.compact
      end
    end
  end
end
