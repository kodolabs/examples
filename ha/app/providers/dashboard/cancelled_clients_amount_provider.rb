module Dashboard
  class CancelledClientsAmountProvider
    def call
      calculate
    end

    private

    def calculate
      Rails.cache.fetch('cancelled_campaigns_amount', expires_in: 4.hours) do
        CampaignsService.joins(campaign: :client)
          .where('clients.active = ?', false)
          .sum(:monthly_spend)
      end
    end
  end
end
