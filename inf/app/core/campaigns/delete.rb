module Campaigns
  class Delete < Rectify::Command
    include Campaigns::AdsService

    def initialize(campaign)
      @campaign = campaign
    end

    def call
      return broadcast(:api_error, fb_last_error) unless fb_delete
      return broadcast(:invalid) unless can_be_deleted? && delete
      broadcast(:ok)
    end

    private

    def fb_delete
      ads_service.delete
    end

    def can_be_deleted?
      true # TODO: check if campaign is running
    end

    def delete
      @campaign.destroy
    end
  end
end
