module Facebook
  class AdsService
    attr_reader :last_error_message

    def initialize(campaign, use_rollbar:)
      @campaign = campaign
      @use_rollbar = use_rollbar
    end

    def sync
      every_object_type do |obj|
        params = object_params(obj)
        next unless params

        if fb_id(obj)
          graph.graph_call("/#{fb_id(obj)}", params, 'post')
        else
          id = graph.put_connections(
            @campaign.fb_ad_account_id, object_name(obj), params
          )['id']
          @campaign.update_column(:"fb_#{obj}_id", id)
        end
      end
    end

    def delete
      every_object_type do |obj|
        return graph.delete_object(fb_id(obj))['success'] if fb_id(obj)
        true
      end
    end

    private

    def every_object_type
      results = %i(campaign adset creative ad).map { |obj| yield(obj) }
      results.compact.map { |res| !!res }.reduce(&:&)
    rescue Koala::Facebook::ClientError => e
      Rollbar.error(e) if @use_rollbar
      @last_error_message = %i(title msg).map do |a|
        e.send(:"fb_error_user_#{a}")
      end.join(': ')
      return false
    end

    def graph
      @graph ||= Koala::Facebook::API.new(account.token)
    end

    def publication
      @publication ||= @campaign.publication
    end

    def account
      @account ||= @campaign.account
    end

    def uid
      @uid ||= publication.uid
    end

    def object_story_id
      return @object_story_id if @object_story_id.present?
      return if uid.blank?
      @object_story_id = if uid.include?('_')
        uid
      else
        "#{publication.owned_page.page.uid}_#{uid}"
      end
    end

    def fb_id(obj)
      @campaign.send(:"fb_#{obj}_id")
    end

    def object_name(obj)
      {
        campaign: 'campaigns',
        adset: 'adsets',
        creative: 'adcreatives',
        ad: 'ads'
      }[obj]
    end

    def object_params(obj)
      send(:"#{obj}_params")
    end

    def campaign_params
      {
        name: @campaign.name,
        objective: 'POST_ENGAGEMENT',
        status: 'PAUSED'
      }
    end

    def adset_params
      {
        name: "#{@campaign.name} [adset]",
        campaign_id: @campaign.fb_campaign_id,
        optimization_goal: 'POST_ENGAGEMENT',
        targeting: targeting.to_json,
        end_time: (@campaign.starts_at + @campaign.duration.days).end_of_day.utc.to_i,
        is_autobid: true,
        billing_event: 'POST_ENGAGEMENT',
        lifetime_budget: (@campaign.budget * 100).to_i
      }.tap do |p|
        p[:status] = 'PAUSED' unless @campaign.fb_adset_id
        if @campaign.fb_adset_id.blank? || @campaign.starts_at >= Time.current
          p[:start_time] = @campaign.starts_at.utc.to_i
        end
      end
    end

    def targeting
      { geo_locations: geo_locations, interests: interests }.tap do |p|
        p[:age_min] = @campaign.age_min if @campaign.age_min
        p[:age_max] = @campaign.age_max if @campaign.age_max
      end
    end

    def creative_params
      return if object_story_id.blank?
      {
        name: "#{@campaign.name} [creative]",
        object_story_id: object_story_id
      }
    end

    def ad_params
      return if object_story_id.blank?
      {
        name: "#{@campaign.name} [ad]",
        adset_id: @campaign.fb_adset_id,
        creative: { creative_id: @campaign.fb_creative_id }.to_json
      }.tap { |p| p[:status] = 'PAUSED' unless @campaign.fb_ad_id }
    end

    def geo_locations
      {
        countries: extract_locations('country').map { |i| i['key'] },
        regions: extract_locations('region').map { |i| { key: i['key'] } },
        cities: extract_locations('city').map { |i| { key: i['key'] } },
        zips: extract_locations('zip').map { |i| { key: i['key'] } }
      }.map { |k, v| [k, v] if v.present? }.compact.to_h
    end

    def extract_locations(type)
      location.select { |i| i['type'] == type }
    end

    def location
      @location ||= JSON.parse(@campaign.location)
    end

    def interests
      JSON.parse(@campaign.interests).map { |i| i['id'] }
    end
  end
end
