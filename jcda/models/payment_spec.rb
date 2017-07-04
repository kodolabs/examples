require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe '.summarize_by_user' do
    let!(:user) { create(:user) }
    let!(:payroll) { create(:payroll) }
    let!(:location) { create(:location) }

    it 'returns grouped payments' do
      payment1 = create :payment, payroll: payroll, location: location,          user: user
      payment2 = create :payment, payroll: payroll, location: location,          user: create(:user)
      payment3 = create :payment, payroll: payroll, location: create(:location), user: user

      result = Payment.summarize_by_user
      expect(result.length).to be 2

      %w(
        regular_hours vacation_hours overtime_hours sick_hours base_pay
        bonus_pay gross_pay
      ).each do |attr|
        expect(result.first.public_send(attr)).to eql payment1.public_send(attr) + payment3.public_send(attr)
        expect(result.second.public_send(attr)).to eql payment2.public_send(attr)
      end
    end
  end
end
