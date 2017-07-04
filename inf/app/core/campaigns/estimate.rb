module Campaigns
  class Estimate < Rectify::Command
    include ActionView::Helpers::NumberHelper

    def initialize(params)
      @params = params
    end

    def call
      res = graph.get_connection(
        @params[:fb_ad_account_id],
        'reachestimate',
        optimize_for: 'POST_ENGAGEMENT',
        targeting_spec: targeting_spec
      )

      { total_users_available: number_with_delimiter(res['data']['users']) }
    rescue
      false
    end

    private

    def publication
      @publication ||= Publication.find(@params[:publication_id])
    end

    def graph
      @graph ||= Koala::Facebook::API.new(publication.account.token)
    end

    def targeting_spec
      { geo_locations: geo_locations, interests: interests }.tap do |p|
        p[:age_min] = @params[:age_min] if @params[:age_min].present?
        p[:age_max] = @params[:age_max] if @params[:age_max].present?
      end
    end

    def interests
      @interests ||= @params[:interests].values.map { |i| i['id'] }
    end

    def location
      @location ||= @params[:location].values
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
  end
end
