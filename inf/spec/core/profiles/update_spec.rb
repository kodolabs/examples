require 'rails_helper'

describe Profiles::Update do
  def empty_params
    { customer: customer, form: {} }
  end

  def params(attrs = {})
    empty_params.deep_merge(form: attrs)
  end

  context 'success' do
    let(:customer) { create(:customer, :with_profile, :with_topics) }
    let(:user) { customer.primary_user }
    let(:profile) { customer.profile }
    let(:form) { Profiles::Form }
    let(:command) { Profiles::Update }
    let(:topic) { create(:topic, :speciality) }
    let(:topic2) { create(:topic, :sub_speciality) }
    let(:topic3) { create(:topic, :interest) }
    let(:profession) { create(:profession, :nurse, :is_active) }

    specify 'update basic info' do
      form_params = {
        profession_id: profession.id,
        full_name: 'Super name',
        date_of_birth: '20/11/1991',
        phone: '+61 4 7819 2350',
        country: 'Australia',
        languages: %w(Arabic Bulgarian),
        time_zone: 'International Date Line West',
        email: 'prof@google.com',
        logo_cache: '',
        speciality_topics: [topic.id],
        sub_speciality_topics: [topic2.id],
        interest_topics: [topic3.id]
      }
      p = params(form_params)
      f = form.from_params(p)
      expect(f.valid?).to be_truthy
      command.call(f, customer)
      updated_profile = customer.primary_user.profile

      expect(updated_profile.full_name).to eq 'Super name'
      expect(updated_profile.time_zone).to eq 'International Date Line West'
      expect(updated_profile.phone).to eq '+61478192350'
      expect(updated_profile.topics).to match_array [topic, topic2, topic3]
    end
  end
end
