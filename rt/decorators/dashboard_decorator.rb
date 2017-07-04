class DashboardDecorator < Draper::Decorator
  delegate_all

  include DashboardDecoratorHelpers

  def time_range
    return nil unless object.posted_in
    "#{object.posted_in.first.strftime(date_from_format)} - #{object.posted_in.last.strftime(date_to_format)}"
  end

  def location_name
    object.location&.name || I18n.t('customer.dashboard.report.header.locations')
  end

  def group_name
    object.group&.name || I18n.t('customer.dashboard.report.header.groups')
  end

  def main_sources_percent
    100 - charts_data[:reviews_by_source][:data].find { |d| d[:id].nil? }&.dig(:percent).to_i
  end

  def main_sources
    @main_sources ||= charts_data[:reviews_by_source][:data]
      .select { |d| d[:id].present? }
      .each do |d|
      d[:logo] ||= object.sources.find { |s| s.id == d[:id] }&.logo
      d[:width] ||= (d[:value].to_f / object.reviews_count * 100).round
    end
  end

  def view_all_sources?
    sources.size > DashboardServices::ReviewBySource::SHOW_COUNT
  end

  def view_all_locations?
    ratings_by_location.size > DashboardServices::ReviewByLocation::SHOW_COUNT
  end

  def expanded_date_chart?
    object.analysis.posted_dates_distance.to_i > 12
  end

  def dates_for_select
    res = [
      OpenStruct.new(label: I18n.t('customer.dashboard.filters.date.values.6_months'), value: 6),
      OpenStruct.new(label: I18n.t('customer.dashboard.filters.date.values.12_months'), value: 12),
      OpenStruct.new(label: I18n.t('customer.dashboard.filters.date.values.2_years'), value: 24)
    ]
    res << OpenStruct.new(label: I18n.t('customer.dashboard.filters.date.values.custom_date'), value: -1) unless Rails.env.production?
    res
  end

  def ratings_by_location_report
    object.ratings_by_location.sort { |a, b| b.new_count <=> a.new_count }
  end

  def location_ratings_title
    ratings_by_location.size == 1 ? I18n.t('customer.dashboard.location_ratings.best_rating') : I18n.t('customer.dashboard.location_ratings.best_ratings')
  end

  def to_json
    {

    }
  end

  private

  def date_from_format
    if object.posted_in.last.year == object.posted_in.first.year
      I18n.t('time.formats.pdf.date_short')
    else
      date_to_format
    end
  end

  def date_to_format
    I18n.t('time.formats.pdf.date_full')
  end
end
