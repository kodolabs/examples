require 'rails_helper'

describe Plans::Update do
  let(:service) { Plans::Update }

  # validations are the same as for Create so no validations tests here

  it 'should update plan' do
    plan = create(:plan)
    form = Plans::PlanForm.from_params(
      plan.attributes.merge(
        id: plan.id,
        name: 'New name',
        price_monthly: 76.54,
        price_annual: 765.4,
        stripe_id_monthly: 'new_stripe_id_monthly',
        stripe_id_annual: 'new_stripe_id_annual'
      )
    )
    service.call(form)
    plan.reload
    expect(plan.name).to eq 'New name'
    expect(plan.price_monthly.to_f).to eq 76.54
    expect(plan.price_annual.to_f).to eq 765.4
    expect(plan.stripe_id_monthly).to eq 'new_stripe_id_monthly'
    expect(plan.stripe_id_annual).to eq 'new_stripe_id_annual'
  end
end
