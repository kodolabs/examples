module ProfileBuilder
  class Spread < Rectify::Command
    DEFAULT_TOPICS = %i(healthcare technology).freeze

    def initialize(profile, customer, user)
      @profile = profile
      @customer = customer
      @user = user
    end

    def call
      %i(profile topics).map do |model|
        send(:"spread_to_#{model}")
      end.reduce(&:&)
      remove_duplicate_fields
      send_mail
    end

    private

    def spread_to_profile
      @profile.update_attributes(
        profession_id: profile_data[:profession],
        time_zone: profile_data[:time_zone],
        full_name: profile_data[:full_name],
        phone: profile_data[:contact_number],
        workplace_ids: profile_data[:workplaces].try(:uniq)
      )
    end

    def spread_to_topics
      topics = {
        speciality: profile_data[:specialities],
        sub_speciality: profile_data[:sub_specialities],
        interest: profile_data[:areas_of_interest]
      }

      topics.each do |topic_type, res|
        next if res.blank?
        topic_ids_uniq = res.flatten.select(&:present?).uniq
        topic_ids = Topic.where(id: topic_ids_uniq).pluck(:id)
        topic_type_val = ProfileTopic.topic_types[topic_type]
        topic_ids.each do |topic_id|
          ProfileTopic.create(
            profile: @profile,
            topic_type: topic_type_val,
            topic_id: topic_id
          )
        end
      end
      @profile.topics << default_topics
    end

    def default_topics
      Topic.where(keyword: DEFAULT_TOPICS)
    end

    def profile_data
      @profile_data ||= @profile.form_params
    end

    def remove_duplicate_fields
      data = profile_data.stringify_keys
      data.delete('profession')
      data.delete('contact_number')
      data.delete('time_zone')
      data.delete('full_name')
      data.delete('specialities')
      data.delete('sub_specialities')
      data.delete('areas_of_interest')
      data.delete('workplaces')
      @profile.update_attributes(data: data.to_json)
    end

    def send_mail
      send_notification
      send_friends_invites
    end

    def send_notification
      @customer.send_notification
    end

    def send_friends_invites
      profile_data[:friends].each { |email| ReferralMailer.share(@customer.object, email).deliver_later }
    end
  end
end
