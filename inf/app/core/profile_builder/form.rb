module ProfileBuilder
  class Form < Rectify::Form
    mimic :form
    required_attributes = %i(
      profession full_name date_of_birth
      contact_number country languages time_zone workplaces
    )
    validates(*required_attributes, presence: true)
    TOPIC_TYPES = %i(specialities sub_specialities areas_of_interest).freeze
    attribute :profession, String
    attribute :specialities, Array
    attribute :sub_specialities, Array
    attribute :areas_of_interest, Array
    attribute :full_name, String
    attribute :date_of_birth, Date
    attribute :contact_number, String
    attribute :country, String
    attribute :languages, Array
    attribute :time_zone, String
    attribute :workplaces, Array
    attribute :friends, Array
    validate :correct_profession
    validate :correct_languages
    validate :correct_country
    validate :correct_timezone
    validate :correct_topics
    validate :correct_workplaces
    validates :contact_number,
      phony_plausible: true,
      format: { with: /\A\+\d+/, message: 'invalid number' }
    validate :plausible_dob
    validate :correct_friends

    def model_data_attributes
      attributes.to_json
    end

    def date_of_birth
      return super if super.is_a?(Date)
      Date.parse(super) rescue nil
    end

    def languages
      [super].flatten.select(&:present?)
    end

    def specialities
      [super].flatten.select(&:present?)
    end

    def sub_specialities
      [super].flatten.select(&:present?)
    end

    def areas_of_interest
      [super].flatten.select(&:present?)
    end

    def workplaces
      [super].flatten.select(&:present?)
    end

    def friends
      [super].flatten.select(&:present?)
    end

    def languages_list
      LanguageList::COMMON_LANGUAGES.map(&:name)
    end

    def contact_number
      PhonyRails.normalize_number(super)
    end

    def min_dob
      100.years.ago
    end

    def max_dob
      18.years.ago
    end

    private

    def plausible_dob
      return if date_of_birth.blank?
      return if (min_dob < date_of_birth) && (max_dob > date_of_birth)
      errors.add(:date_of_birth, 'not realistic age')
    end

    def correct_languages
      return if languages.none?
      extra = languages - languages_list
      errors.add(:languages, :inclusion) if extra.any?
    end

    def correct_profession
      return if profession.blank?
      return if Profession.pluck(:id).map(&:to_s).include?(profession)
      errors.add(:profession, :inclusion)
    end

    def correct_workplaces
      return if workplaces.blank?
      ids = Workplace.pluck(:id).map(&:to_s)
      extra = workplaces.find { |input_id| !ids.include?(input_id) }
      errors.add(:workplaces, :inclusion) if extra.present?
    end

    def correct_country
      return if country.blank? || ISO3166::Country[country].present?
      errors.add(:country, :inclusion)
    end

    def correct_timezone
      return if time_zone.blank?
      return if ActiveSupport::TimeZone::MAPPING[time_zone].present?
      errors.add(:time_zone, :inclusion)
    end

    def correct_topics
      TOPIC_TYPES.each do |topic_type|
        return if send(topic_type).blank?
        extra = send(topic_type).flatten.map(&:to_i) - topic_list_for(topic_type)
        errors.add(topic_type, :inclusion) if extra.any?
      end
    end

    def correct_friends
      return if friends.blank?
      return if friends.all? { |friend| friend =~ email_regexp }
      errors.add(:friends, :invalid)
    end

    def email_regexp
      /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    end

    def topic_list_for(topic_type)
      scope = case topic_type
      when :specialities then :speciality
      when :sub_specialities then :sub_speciality
      when :areas_of_interest then :interest
      end
      Topic.send(scope).pluck(:id)
    end
  end
end
