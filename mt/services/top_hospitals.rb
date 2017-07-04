class TopHospitals
  TOP_HOSPITALS_LIMIT = 5
  INTERVAL_LENGTH = 2 # in hours
  LIMIT_THESHOLD = 12 # in hours

  def initialize(demand)
    @demand = demand
    @proposals = @demand.enquiries.with_proposed_state.includes(
      hospital: [:accreditations, :amenities, :location], proposal: []
    )
  end

  def select
    return @proposals unless @demand.multiple_hospitals?
    available_proposals.first(TOP_HOSPITALS_LIMIT)
  end

  private

  def available_proposals
    return @proposals if hours_from_created >= LIMIT_THESHOLD
    available = @proposals.where('updated_at <= ?', closest_interval_finish)
    return [] if available.count < TOP_HOSPITALS_LIMIT
    sorted_proposals
  end

  def sorted_proposals
    sorted_proposals = @proposals.sort_by { |p| p.proposal.price }.reverse
    sorted_proposals = sorted_proposals.each_with_index.map do |proposal, index|
      points = proposal.hospital.rating.to_f / 10
      points += proposal.hospital.accreditations.count
      points += index + 1
      points += 5 if proposal.hospital.plus_partner?
      [proposal, points]
    end
    sorted_proposals.sort_by { |_proposal, points| points }.reverse.map(&:first)
  end

  def closest_interval_finish
    full_hours = (hours_from_created.to_i / INTERVAL_LENGTH) * INTERVAL_LENGTH
    @demand.created_at + full_hours.hours
  end

  def hours_from_created
    TimeDifference.between(Time.now, @demand.created_at).in_hours
  end
end
