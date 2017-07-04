module Dashboard
  class AddedClientsProvider < BaseRecentClientsProvider
    private

    def clients_collection
      @clients ||= Client.includes(:campaigns).active.by_created_date.last(10)
    end

    def calculate(client)
      campaign_ids = client.campaigns.active.pluck(:id)
      CampaignsService.where(campaign_id: campaign_ids).sum(:monthly_spend)
    end

    def date(client)
      client.created_at.to_s(:short)
    end
  end
end
