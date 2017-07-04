class Dashboard
  CHART_OPTIONS = {
    reviews_by_date: {
      show_reviews: true
    },
    reviews_by_source: {},
    average_rating_by_date: {
      show_reviews: false
    }
  }.freeze

  RECENT_REVIEWS_LIMIT = 40

  attr_reader :analysis
  delegate :customer, :user, :location, :posted_in, :group, :location, :reviews_count, :sources_by_count, to: :analysis

  def initialize(customer, user, opts = {})
    @analysis = DashboardServices::Analysis.new(customer, user, opts)
  end

  def reviews_avg_rating
    avg = analysis.reviews_count_query.avg
    avg.nil? ? '-' : avg.round(1)
  end

  def best_source
    analysis.sorted_source_query.first&.name
  end

  def worst_source
    analysis.sorted_source_query.last&.name
  end

  def sources
    @sources ||= begin
      sources = analysis.sorted_source_query.to_a
      nil_reviews_for_sources sources
      sources = sources.sort { |a, b| [b.avg.to_f, b.name.to_s] <=> [a.avg.to_f, a.name.to_s] }
        .each_with_index do |r, i|
        r.percent = (r.count.to_f / reviews_count * 100).round
        r.color = DashboardServices::Analysis::COLORS[i % DashboardServices::Analysis::COLORS.length]
      end
      ReviewBySourceDecorator.decorate_collection(sources)
    end
  end

  def ratings_by_location
    @locations ||= begin
      locations = analysis.base_reviews_by_location_query.with_rating.to_a
      nil_reviews_for_locations locations
      ReviewByLocationDecorator.decorate_collection(locations.sort { |a, b| b.avg.to_f <=> a.avg.to_f })
    end
  end

  def locations_for_select
    relation = analysis.group ? analysis.group.locations : customer.locations
    relation.where(id: user.available_locations).select(:id, :name).where(<<-SQL.squish).order(name: :asc)
    EXISTS (
     SELECT 1 FROM reviews WHERE reviews.location_id = locations.id
    )
    SQL
  end

  def groups_for_select
    LocationGroup.joins(:locations)
      .where(customer: customer)
      .where('locations.id IN (?)', user.available_locations.pluck(:id))
      .select(:id, :name)
      .where(<<-SQL.squish).order(name: :asc)
    EXISTS (
     SELECT 1 FROM reviews WHERE reviews.location_id = locations.id
    )
    SQL
  end

  def recent_reviews
    @recent_reviews ||= analysis.base_reviews_query.includes(:source, :location).order(posted_at: :desc).limit(RECENT_REVIEWS_LIMIT)
  end

  private

  def nil_reviews_for_sources(sources)
    analysis.source_query.without_rating.each do |s|
      source = sources.find { |ss| ss.id == s.id }
      if source
        source.count += s.count
      else
        sources << s
      end
    end
  end

  def nil_reviews_for_locations(locations)
    analysis.base_reviews_by_location_query.without_rating.each do |r|
      location = locations.find { |l| l.id == r.id }
      if location
        location.new_count += r.new_count
        location.count += r.count
      else
        location = r
        locations << location
      end
      location.without_rating = r.count
    end
  end
end
