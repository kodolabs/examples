class Dashboard

  include Measurements

  INTERVAL = 24.hours

  STEP = 4.hours
  SEGMENT = 30.minutes

  attr_accessor :sources

  def initialize
    @sources = Source.order(name: :asc).all
  end

  def charts_data
    @charts_data ||= {
      requests_data: requests_data,
      page_loading_data: page_loading_data
    }
  end

  def requests_data
    logs = Log.find_by_sql requests_query
    sql_data = group_by_recursive(logs, model: Log, attribute: 'requests_count', fields: [:source_id, :status, :interval_alias])

    result = empty_requests_data.deep_merge(sql_data)
    format_for_chartjs(result, graphic: 'requests')
  end

  def page_loading_data
    logs = Log.find_by_sql benchmark_query
    sql_data = group_by_recursive(logs, model: Log, attribute: 'measurements', action: 'percentile', fields: [:source_id, :interval_alias])

    result = empty_page_loading_data.deep_merge(sql_data)
    format_for_chartjs(result, graphic: 'page_loading')
  end

  def request_data_types
    %w(success error)
  end

  def requests_data_exists?
    charts_data[:requests_data].present?
  end

  def page_loading_data_exists?
    charts_data[:page_loading_data].present?
  end

  private

  def segment_value
    SEGMENT.to_i
  end

  def step_value
    STEP.to_i
  end

  def format_for_chartjs(result, options)
    graphic = options[:graphic]
    result.map do |source_id, source_batch|

      if options[:graphic] == 'page_loading'
        batch = { labels: labels_for(source_batch.keys), values: source_batch.values }
      else
        batch = source_batch.map do |logs_status, status_batch|
          chartjs_data = { labels: labels_for(status_batch.keys), values: status_batch.values }
          [logs_status, chartjs_data]
        end.to_h
      end

      [source_id, batch]
    end.to_h
  end

  def requests_query
    <<-SQL
      SELECT channels.source_id, logs.status, COUNT(*) requests_count,
       to_timestamp(floor((extract('epoch' FROM logs.created_at) / '#{segment_value}' )) * '#{segment_value}')
       AT TIME ZONE 'UTC' AS interval_alias
       FROM logs
       INNER JOIN "channels" ON "logs"."channel_id" = "channels"."id"
       WHERE logs.created_at > '#{Time.now.utc - INTERVAL}'
       GROUP BY channels.source_id, logs.status, interval_alias
       ORDER BY interval_alias
    SQL
  end

  def benchmark_query
    <<-SQL
      SELECT channels.source_id, array_agg("logs"."process_time") measurements,
       to_timestamp(floor((extract('epoch' FROM logs.created_at) / '#{segment_value}' )) * '#{segment_value}')
       AT TIME ZONE 'UTC' AS interval_alias
       FROM logs
       INNER JOIN "channels" ON "logs"."channel_id" = "channels"."id"
       WHERE logs.created_at > '#{Time.now.utc - INTERVAL}'
       GROUP BY channels.source_id, interval_alias
       ORDER BY interval_alias
    SQL
  end

  # Round time to nearest SEGMENT
  def round_time_for(time)
    Time.at((time.to_i / segment_value).floor * segment_value).utc.to_i
  end

  # {"00:00" => 0, "00:10" => 0 ...} between INTERVAL and current time
  def empty_interval_data
    current_time = Time.now.utc

    start_date = round_time_for(current_time - INTERVAL)
    end_date = round_time_for current_time

    range = (start_date..end_date).step(segment_value)
    segments = range.map { |val| Time.at(val).utc }

    Hash[segments.map {|s| [s, 0]}]
  end

  def empty_requests_data
    empty_data(values: :empty_status_data)
  end

  def empty_page_loading_data
    empty_data(values: :empty_interval_data)
  end

  # Generate data per source {1=>{}, 2=>{}, 3=>{}, 4=>{}, 5=>{}, 6=>{}}
  def empty_data(options)
    values = send options[:values]
    Hash[ @sources.pluck(:id).map { |id| [id, values] } ]
  end

  # {"success"=>{}, "error"=>{}, "warning"=>{}}
  def empty_status_data
    Hash[ Log.statuses.keys.map { |s| [s, empty_interval_data] } ]
  end

  # Generate labels every STEP
  # if label is not needed, set empty string - https://github.com/chartjs/Chart.js/pull/521
  def labels_for(timestamps)
    start_point = timestamps.first.beginning_of_hour
    end_point = timestamps.last.beginning_of_hour
    visible_labels = (start_point.to_i..end_point.to_i).step(step_value).map { |val| Time.at(val).utc }
    timestamps.map { |t| visible_labels.include?(t) ? t.strftime("%H:%M") : "" }
  end

  def group_by_recursive(hash, options)
    replace_percentile = options[:action].present? && options[:action] == 'percentile'
    replace_value = options[:attribute].present? && options[:model].present?
    fields, attribute, action = options[:fields], options[:attribute], options[:action]

    groups = hash.group_by(&fields.first)

    if fields.count == 1
      if replace_percentile
        groups.map {|k, v| [k, percentile_for(v.first.send(attribute)).round(2)] }.to_h
      elsif replace_value
        groups.map {|k, v| [k, v.first.send(attribute)] }.to_h
      else
        groups
      end
    else
      opts = options.merge(fields: fields.drop(1))

      groups.merge(groups) do |group, elements|
        group_by_recursive(elements, opts)
      end
    end
  end

end
