module Campaigns
  module AdsService
    def ads_service
      @ads_service ||= Facebook::AdsService.new(@campaign, use_rollbar: false)
    end

    def fb_last_error
      ads_service.last_error_message
    end
  end
end
