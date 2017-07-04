module Campaigns
  class Update < Rectify::Command
    include Campaigns::AdsService

    def initialize(form)
      @form = form
    end

    def call
      return broadcast(:invalid) if @form.invalid?
      init
      return broadcast(:invalid) unless save
      return broadcast(:api_error, fb_last_error) unless fb_update
      broadcast(:ok)
    end

    private

    def init
      @campaign = Campaign.find(@form.id)
      @campaign.assign_attributes(@form.model_attrs(except: :publication_id))
    end

    def save
      @campaign.save
    end

    def fb_update
      ads_service.sync
    end
  end
end
