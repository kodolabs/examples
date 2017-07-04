require 'rails_helper'

describe Plans::Destroy do
  let(:service) { Plans::Destroy }

  it 'should destroy given plan' do
    plan = create(:plan)
    expect(plan.persisted?).to be_truthy
    service.call(plan)
    expect(plan.persisted?).to be_falsey
  end
end
