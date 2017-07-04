require 'rails_helper'

describe ProfileBuilder::Spread do
  context 'success' do
    let(:default_topic_keywords) { ProfileBuilder::Spread::DEFAULT_TOPICS.map(&:to_s) }

    context 'spread all fields' do
      let(:topic1) { create(:topic, :speciality) }
      let(:topic2) { create(:topic) }
      let(:topic3) { create(:topic) }
      let(:customer) { create(:customer, :with_user) }
      let(:profession) { create(:profession, :nurse) }
      let(:friends_mailer) { ReferralMailer }
      let(:profile) do
        profession
        create(:profile, :before_spread, user: customer.primary_user,
                                         data: { specialities: [topic1.id], profession: profession.id })
      end

      let(:user) { customer.primary_user }
      let(:default_topics) do
        default_topic_keywords.each do |k|
          create(:topic, keyword: k)
        end
      end

      specify 'success' do
        default_topics
        profile
        synced_data = JSON.parse(profile.data).with_indifferent_access

        values_presence = synced_data.values.all?(&:present?)
        expect(values_presence).to be_truthy
        fields_before_spread = %w(
          full_name date_of_birth contact_number
          languages time_zone country specialities
          profession workplaces friends
        )
        expect(synced_data.keys).to match_array fields_before_spread

        expect(customer).to receive(:send_notification).once
        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(friends_mailer).to receive(:share).and_return(message_delivery)
        expect(message_delivery).to receive(:deliver_later).once
        ProfileBuilder::Spread.new(profile, customer.decorate, user).call

        user.reload
        expect(profile.full_name).to eq synced_data[:full_name]
        expect(profile.date_of_birth).to eq synced_data[:date_of_birth]
        expect(profile.phone).to eq synced_data[:contact_number].delete(' ')
        expect(profile.time_zone).to eq synced_data[:time_zone]
        expect(profile.country).to eq synced_data[:country]
        expect(profile.languages).to eq synced_data[:languages]
        expect(profile.interest_topics.pluck(:keyword)).to match_array default_topic_keywords
        expect(profile.speciality_topics).to match_array [topic1]
        expect(profile.profession).to eq profession
        expect(profile.workplaces.pluck(:title)).to eq ['before_spread']
      end
    end
  end
end
