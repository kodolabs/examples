module Campaigns
  class Create < Rectify::Command
    include Campaigns::AdsService

    def initialize(form)
      @form = form
    end

    def call
      return broadcast(:invalid) if @form.invalid?
      init
      return broadcast(:invalid) unless save
      return broadcast(:api_error, fb_last_error) unless fb_create
      broadcast(:ok)
    end

    private

    def init
      @campaign = Campaign.new(@form.model_attrs)
    end

    def save
      @campaign.save
    end

    def fb_create
      ads_service.sync
    end
  end
end
