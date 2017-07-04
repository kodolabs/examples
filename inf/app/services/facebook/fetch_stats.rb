class Facebook::FetchStats
  DATE_OFFSET = 1.day

  def initialize(page, options = {})
    @page = page
    @since = options[:since]
  end

  def call
    return if @page.blank?
    account = @page.owned_pages.try(:first).try(:account)
    return if account.blank?

    graph = Koala::Facebook::API.new(account.token)

    fetch_stats(graph, @page)
    @page.touch_owned_pages
  rescue Koala::Facebook::AuthenticationError
    false
  end

  private

  def base_options
    { since: @since || 3.months.ago.to_i, until: Time.current.to_i, period: 'day' }
  end

  def fetch_stats(graph, page)
    result = graph.batch do |batch_api|
      Facebook::FetchInteractions.new(batch_api, page, interactions_options).call
      Facebook::FetchPageViews.new(batch_api, page, page_views_options).call
      Facebook::FetchPageLikes.new(batch_api, page, base_options).call
      Facebook::FetchDemographics.new(batch_api, page, demographics_options).call
      Facebook::FetchGenders.new(batch_api, page, base_options).call
      Facebook::FetchConnections.new(batch_api, page, base_options).call
      Facebook::FetchPaidConnections.new(batch_api, page, base_options).call
    end
    save_interactions(result)
    save_page_views(result)
    save_page_likes(result)
    save_demographics(result)
    save_genders(result)
    save_connections(result)
    save_paid_connections(result)
  end

  def page_likes_options
    base_options
  end

  def demographics_options
    { since: @since || 2.days.ago.to_i, period: 'days_28' }
  end

  def interactions_options
    { since: @since || Time.current.beginning_of_year.to_i, period: 'day' }
  end

  def page_views_options
    base_options.merge(period: 'days_28')
  end

  def save_interactions(result)
    save_insights_stats(result, field: 'engaged_users', index: 0)
  end

  def save_page_views(result)
    save_insights_stats(result, field: 'views', index: 1)
  end

  def save_page_likes(result)
    save_insights_stats(result, field: 'likes', index: 2)
  end

  def save_demographics(result)
    save_demographics_data(result, 3)
  end

  def save_genders(result)
    save_insights_stats(result, field: 'genders_count', index: 4)
  end

  def save_connections(result)
    save_insights_stats(result, field: 'connections', index: 5)
  end

  def save_paid_connections(result)
    save_insights_stats(result, field: 'paid_connections', index: 6)
  end

  def save_demographics_data(data, index)
    return if data[index].blank?
    return unless data[index].is_a?(Array)

    data[index].each do |metric_data|
      values = metric_data['values'].first
      name = metric_data['name']

      field_name = field_name_for(name)
      next if field_name.blank?
      metric_type = metric_type_for(name)

      date = Date.parse values['end_time']
      value = values['value']

      history = @page.demographics.find_by(date: date, metric_type: metric_type)
      history ||= @page.demographics.new

      if history.new_record?
        history.attributes = { field_name => value }
        history.date = date
        history.metric_type = metric_type
        history.save
      else
        history.send "#{field_name}=", value
        history.save if history.changed?
      end
    end
  end

  def save_insights_stats(result, options)
    field = options[:field]
    index = options[:index]
    metric_data = result.try(:[], index).try(:first)
    return if metric_data.blank?

    values = metric_data['values']
    period = metric_data['period']

    values.each do |metric_field|
      date = Date.parse(metric_field['end_time']) - DATE_OFFSET
      value = format_value(metric_field['value'], options)

      history = @page.histories.find_by(date: date, period: period)
      history ||= @page.histories.new(period: period, date: date)

      case field
      when 'genders_count'
        history.males = value[:males]
        history.females = value[:females]
      else
        history.send "#{field}=", value
      end

      history.save if history.changed?
    end
  end

  def format_value(val, options)
    field = options[:field]
    case field
    when 'genders_count'
      count_males_and_females(val, options)
    else
      val
    end
  end

  def count_males_and_females(val, _options)
    males = val.presence ? val.select { |str| str.start_with?('M.') }.length : 0
    females = val.presence ? val.select { |str| str.start_with?('F.') }.length : 0
    {
      males: males,
      females: females
    }
  end

  def field_name_for(field)
    case field
    when 'page_engaged_users'
      'engaged_users'
    when 'page_fans'
      'likes'
    when 'page_views_total'
      'views'
    when 'page_fans_country', 'page_story_adds_by_country_unique', 'page_impressions_by_country_unique'
      'countries'
    when 'page_fans_gender_age', 'page_storytellers_by_age_gender', 'page_impressions_by_age_gender_unique'
      'genders'
    end
  end

  def metric_type_for(field)
    reached_fields = %w(
      page_storytellers_by_locale
      page_story_adds_by_country_unique
      page_story_adds_by_city_unique
      page_storytellers_by_age_gender
    )

    engaged_fields = %w(
      page_impressions_by_locale_unique
      page_impressions_by_country_unique
      page_impressions_by_city_unique
      page_impressions_by_age_gender_unique
    )

    fans_fields = %w(page_fans_locale
                     page_fans_country
                     page_fans_city
                     page_fans_gender_age)

    return 'fans' if fans_fields.include?(field)
    return 'reached' if reached_fields.include?(field)

    'engaged' if engaged_fields.include?(field)
  end
end
