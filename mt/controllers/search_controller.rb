class SearchController < ApplicationController
  def index
    @data = Search::Hospital.new(params).results
    @demand = Demand.new
    select_values
    assign_meta_tags
  end

  def select_values
    procedures = [Selectize::Procedure::PublicBuilder.new(@data.procedure).build].compact
    locations = [Selectize::Location::PublicBuilder.new(@data.location).build].compact

    gon.push(
      procedures: procedures.blank? ? nil : procedures,
      locations: locations.blank? ? nil : locations
    )
  end

  private

  def assign_meta_tags
    results_count = @data.results_count
    title, description = if @data.procedure && @data.location
      [
        "Best #{@data.procedure.name} treatment in #{@data.location.name}",
        "The best hospitals and clinics for #{@data.procedure.name} treatment in #{@data.location.name}."
      ]
    elsif @data.procedure
      [
        "Best #{@data.procedure.name} treatment",
        "The best #{results_count} international hospitals and clinics for #{@data.procedure.name} treatment."
      ]
    elsif @data.location
      [
        "Best treatment in #{@data.location.name}",
        "The best #{results_count} hospitals and clinics for treatment in #{@data.location.name}."
      ]
    else
      [
        "Best treatment at #{results_count} international hospital",
        "The best #{results_count} international hospitals and clinics."
      ]
    end
    description += ' Accredited, reviewed healthcare selected by leading doctors.'
    set_meta_tags(title: title, description: description, reverse: true)
  end
end
