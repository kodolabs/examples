module Facebook
  class TrackCampaignService
    def initialize(campaign)
      @campaign = campaign
    end

    def call
      %i(campaign adset creative ad).each do |item|
        next unless @campaign.send("fb_#{item}_id")
        send("update_#{item}")
      end
      cleanup_campaign
    end

    private

    def update_campaign
      data = graph.get_object(
        @campaign.fb_campaign_id, fields: %i(name status)
      ).with_indifferent_access
      return unless active_status?(data, :fb_campaign_id)
      @campaign.update_columns(name: data[:name])
    rescue Koala::Facebook::ClientError => e
      process_error(e, :fb_campaign_id)
      return false
    end

    def update_adset
      data = graph.get_object(
        @campaign.fb_adset_id, fields: %i(
          targeting start_time end_time lifetime_budget budget_remaining status
        )
      ).with_indifferent_access
      return unless active_status?(data, :fb_campaign_id)
      @campaign.update_columns(
        interests: interests(data),
        location: location(data),
        starts_at: Time.zone.parse(data[:start_time]),
        duration: duration(data[:start_time], data[:end_time]),
        budget: data[:lifetime_budget].to_f / 100,
        budget_remaining: data[:budget_remaining].to_f / 100
      )
    rescue Koala::Facebook::ClientError => e
      process_error(e, :fb_adset_id)
      return false
    end

    def update_creative
      graph.get_object(@campaign.fb_creative_id)
    rescue Koala::Facebook::ClientError => e
      process_error(e, :fb_creative_id)
      return false
    end

    def update_ad
      data = graph.get_object(@campaign.fb_ad_id, fields: %i(status))
      active_status?(data, :fb_campaign_id)
    rescue Koala::Facebook::ClientError => e
      process_error(e, :fb_ad_id)
      return false
    end

    def cleanup_campaign
      return if @campaign.publication.uid.blank?
      return if @campaign.fb_campaign_id.present?
      @campaign.destroy
    end

    def interests(data)
      interests = data[:targeting][:interests]
      interests ||= data[:targeting][:flexible_spec].first[:interests]
      interests.map { |i| i.slice(:id, :name) }.to_json
    end

    def location(data)
      %i(countries regions cities zips).map do |t|
        send("extract_#{t}", data[:targeting][:geo_locations][t])
      end.flatten.compact.to_json
    end

    def extract_countries(data)
      (data || []).map do |key|
        name = ISO3166::Country.new(key).name
        { key: key, name: name, type: :country, country_name: name }
      end
    end

    def extract_regions(data)
      (data || []).map do |r|
        {
          key: r['key'], name: r['name'], type: :region,
          country_name: ISO3166::Country.new(r['country']).name
        }
      end
    end

    def extract_cities(data)
      (data || []).map do |c|
        {
          key: c['key'], name: c['name'], type: :city, region: c['region'],
          country_name: ISO3166::Country.new(c['country']).name
        }
      end
    end

    def extract_zips(data)
      (data || []).map do |z|
        {
          key: z['key'], name: z['name'], type: :zip,
          country_name: ISO3166::Country.new(z['country']).name
        }
      end
    end

    def duration(starts, ends)
      (Time.zone.parse(ends).to_date - Time.zone.parse(starts).to_date).to_i
    end

    def active_status?(data, column)
      return true unless data['status'] == 'ARCHIVED'
      @campaign.update_column(column, nil)
    end

    def process_error(e, column)
      if 'does not exist'.in?(e.message)
        @campaign.update_column(column, nil)
      else
        Rollbar.error(e)
      end
    end

    def graph
      @graph ||= Koala::Facebook::API.new(@campaign.account.token)
    end
  end
end
