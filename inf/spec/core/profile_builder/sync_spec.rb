require 'rails_helper'

describe ProfileBuilder::Sync do
  context 'success' do
    let(:command) { ProfileBuilder::Sync }
    let(:customer) { create(:customer, :with_user) }
    let(:user) { customer.primary_user }
    let(:profession) { create(:profession, :nurse) }
    let(:form) { ProfileBuilder::Form }
    let(:setting) { create(:setting, var: 'general.trial_length_days', value: '2') }

    specify 'set trial' do
      setting
      allow_any_instance_of(form).to receive(:valid?).and_return(true)
      allow_any_instance_of(form).to receive(:invalid?).and_return(false)

      f = form.new(profession: profession.id, contact_number: '+12312312311')
      command.new(f, customer, user).call
      expect(customer.reload.trial_ends_on).to eq(2.days.from_now.to_date)
      profile = customer.primary_user.profile
      expect(profile.profession).to eq(profession)
    end
  end
end
