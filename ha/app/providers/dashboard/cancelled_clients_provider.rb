module Dashboard
  class CancelledClientsProvider < BaseRecentClientsProvider
    private

    def clients_collection
      @clients ||= Client.includes(:campaigns).inactive.by_cancelled_date.last(10)
    end

    def calculate(client)
      campaign_ids = client.campaigns.inactive.pluck(:id)
      CampaignsService.where(campaign_id: campaign_ids).sum(:monthly_spend)
    end

    def date(client)
      client.cancelled_at&.to_s(:short)
    end
  end
end
