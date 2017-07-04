module Campaigns
  class Form < Rectify::Form
    mimic :campaign

    attribute :name, String
    attribute :starts_at, Time
    attribute :start_date, String
    attribute :start_time, String
    attribute :end_date, String
    attribute :duration, Integer
    attribute :interests, String
    attribute :location, String
    attribute :age, String
    attribute :age_min, Integer
    attribute :age_max, Integer
    attribute :budget, Integer
    attribute :fb_ad_account_id, String

    attribute :customer, Customer
    attribute :publication_id, Integer

    present_attrs = %i(name starts_at duration budget fb_ad_account_id)
    validates(*present_attrs, presence: true)
    validate :uniq_name
    # validate :correct_duration
    validate :correct_budget
    validate :interests_presence
    validate :location_presence
    validates :age_min, allow_blank: true,
      numericality: {
        only_integer: true,
        greater_than_or_equal_to: 18,
        less_than_or_equal_to: 65
      }
    validates :age_max, allow_blank: true,
      numericality: {
        only_integer: true,
        greater_than_or_equal_to: 18,
        less_than_or_equal_to: 65
      }
    # TODO: validate reasonable time based on post created/scheduled datetime

    def model_attrs(except: [])
      attrs = %i(
        name starts_at duration budget fb_ad_account_id interests location
        age_min age_max
      )
      attrs << :publication_id unless [except].flatten.include?(:publication_id)
      attributes.slice(*attrs)
    end

    def starts_at(override = true)
      return super() unless override
      super() || start_date.try(:+, start_time_seconds)
    end

    def start_date
      return Date.strptime(super, '%m/%d/%Y') if super.present?
      starts_at(false).try(:strftime, '%m/%d/%Y')
    end

    def start_time
      return Time.strptime(super, '%H:%M') if super.present?
      starts_at(false).try(:strftime, '%H:%M')
    end

    def start_time_seconds
      start_time.seconds_since_midnight.seconds rescue 0
    end

    def end_date
      return Date.strptime(super, '%m/%d/%Y') if super.present?
      return unless duration.present?
      starts_at(false).try(:+, duration.days).try(:strftime, '%m/%d/%Y')
    end

    def duration
      super.present? ? super.to_i : nil
    end

    def interests
      json_attr(super)
    end

    def location
      json_attr(super)
    end

    def age
      "From #{age_min(false) || 18} to #{age_max(false) || 65}"
    end

    def age_min(override = true)
      return super() unless override
      super().presence || age_as_array.first
    end

    def age_max(override = true)
      return super() unless override
      super().presence || age_as_array.last
    end

    def publication
      @publication ||= Publication.find(publication_id)
    end

    def no_data?
      model_attrs.map do |k, v|
        return JSON.parse(v).blank? if k.in?(%i(interests location))
        v.blank?
      end.reduce(&:&)
    end

    private

    def uniq_name
      with_same_name = customer.campaigns
        .where('lower(name) = lower(?)', name).where.not(id: id)
      return if with_same_name.none?
      errors.add(:name, :taken)
    end

    def correct_duration
      return if duration.blank?
      errors.add(:duration, :greater_than, count: 0) if duration < 1
      return if starts_at.blank?
      max_date = Time.current + 1.year
      current_max_date = starts_at + duration.days
      return if current_max_date < max_date
      available_duration = (max_date.to_date - starts_at.to_date).to_i
      errors.add(:duration, :less_than, count: available_duration)
    end

    def correct_budget
      return if duration.blank? || budget.blank?
      return if errors.keys.include?(:duration)
      min_budget = duration * 5
      return if budget.to_f >= min_budget
      errors.add(:budget, :greater_than_or_equal_to, count: min_budget)
    end

    def interests_presence
      return if JSON.parse(interests).present?
      errors.add(:interests, :blank)
    end

    def location_presence
      return if JSON.parse(location).present?
      errors.add(:location, :blank)
    end

    def json_attr(object)
      return '[]' if object.blank?
      "[#{object.gsub(/[\[\]]+/, '').gsub('}|{', '},{')}]"
    end

    def age_as_array
      raw_array = age.match(/From(.+)to(.+)/)[1..2]
      raw_array.map! { |a| a.gsub(/\D+/, '') }.map!(&:to_i)
      raw_array.map { |a| a == 0 ? nil : a }
    end
  end
end
