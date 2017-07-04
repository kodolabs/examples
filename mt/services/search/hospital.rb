class Search::Hospital
  PER_PAGE = 10
  DEFAULT_SORT_QUERY = { name: :asc }.freeze
  attr_reader :params, :procedure, :location, :search, :skip_location_filters, :sort

  def initialize(params = {})
    @params = params
    @procedure = Procedure.find_by(slug: params[:procedure])
    @location = Location.find_by(slug: params[:location])
    @sort = params[:sort]
  end

  def results
    validate_location_filters
    set_search
    modify_location_search

    records = search.page(params[:page]).per(PER_PAGE).records
    records = EagerPagination.new(records, :eager)

    OpenStruct.new(
      procedure: procedure,
      location: location,
      results: records,
      results_count: records.total_count,
      aggregations: search.aggregations,
      sort: sort
    )
  end

  private

  def set_search
    @search = ::Hospital.search(query: {
      function_score: {
        filter: query_filter,
        functions: query_functions
      }
    },
                                aggs: aggregations,
                                post_filter: post_filter,
                                sort: apply_sort('rating'))
  end

  def modify_location_search
    return unless location && search.results.empty?
    @skip_location_filters = true

    @search = ::Hospital.search(query: {
      function_score: {
        filter: query_filter,
        functions: query_functions
      }
    },
                                aggs: aggregations,
                                post_filter: post_filter,
                                sort: apply_sort('distance_search'))
  end

  def validate_location_filters
    if params[:countries].to_a.any? && params[:regions].to_a.any?
      region_ids = Location.where(name: params[:regions], ancestry_depth: 0).pluck(:id)
      countries = Location.where(name: params[:countries], ancestry_depth: 1).pluck(:ancestry, :name)

      countries.each do |country|
        next if country[0].to_i.in?(region_ids)

        params[:countries].delete(country[1])
      end
    end
  end

  def query_filter
    terms = []
    terms << { term: { visible: true } }

    if procedure
      terms << {
        nested: {
          path: 'procedures',
          filter: { term: { 'procedures.id' => procedure.id } }
        }
      }
    end

    if location && !skip_location_filters
      terms << { term: { region: location.root.name } }
    end

    terms << { term: { plus_partner: true } } if params[:plus] == 'on'

    apply_filter(terms)
  end

  def query_functions
    functions = []

    return functions unless location && !skip_location_filters

    case location.depth
    when 1
      functions << { filter: { term: { country: location.name } }, weight: 2 }
    when 2
      functions += [
        { filter: { term: { country: location.parent.name } }, weight: 2 },
        { filter: { term: { city: location.name } }, weight: 2 }
      ]
    end

    functions
  end

  def post_filter
    terms = []
    terms << { terms: { region: params[:regions] } } if [*params[:regions]].any?
    terms << { terms: { country: params[:countries] } } if [*params[:countries]].any?
    apply_filter(terms)
  end

  def apply_filter(terms)
    filter = {}
    filter[:and] = terms if terms.any?
    filter
  end

  def apply_sort(default)
    @sort = default if params[:sort].blank?
    sort_object = []
    sort_object << '_score' if location
    sort_object << sort_map.fetch(params[:sort], sort_map[default])
  end

  def sort_map
    order = params[:sort].to_s.split('_').last
    order = 'asc' unless order.in? %w(asc desc)

    map = {
      "cost_#{order}" => {
        'procedures.price_from' => {
          mode: 'min',
          order: order,
          missing: '_last',
          nested_path: 'procedures',
          nested_filter: { term: { 'procedures.id' => procedure.try(:id).to_i } }
        }
      },
      'rating' => { rating: :desc },
      'distance_me' => {
        '_geo_distance' => {
          'coordinates' => {
            lat: params[:latitude].to_f,
            lon: params[:longitude].to_f
          },
          order: 'asc',
          unit: 'km',
          mode: 'min',
          distance_type: 'sloppy_arc'
        }
      },
      'distance_search' => distance_to_search
    }

    map["cost_#{order}"] = DEFAULT_SORT_QUERY unless procedure
    map
  end

  def distance_to_search
    country = iso_country

    return DEFAULT_SORT_QUERY unless country

    {
      '_geo_distance' => {
        'coordinates' => {
          lat: country.latitude_dec.to_f,
          lon: country.longitude_dec.to_f
        },
        order: 'asc',
        unit: 'km',
        mode: 'min',
        distance_type: 'sloppy_arc'
      }
    }
  end

  def iso_country
    return nil unless location

    country = location.path.find_by(ancestry_depth: 1) || location.path.find_by(ancestry_depth: 0).children.first
    ISO3166::Country.find_country_by_name(country.try(:name))
  end

  def aggregations
    terms = []
    terms << { terms: { region: params[:regions] } } if [*params[:regions]].any?

    {
      region: {
        terms: {
          field: 'region',
          size: 0,
          order: { '_term' => 'asc' }
        }
      },
      filtered_country: {
        filter: apply_filter(terms),
        aggs: {
          country: {
            terms: {
              field: 'country',
              size: 0,
              order: { '_term' => 'asc' }
            }
          }
        }
      }
    }
  end
end
