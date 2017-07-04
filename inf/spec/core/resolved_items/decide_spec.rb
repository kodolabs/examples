require 'rails_helper'

describe ResolvedItems::Decide do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:news) { create(:news) }
  let(:command) { ResolvedItems::Decide }
  let(:invalid_form) { ResolvedItems::DecisionForm.from_params({}) }
  let(:valid_form) do
    ResolvedItems::DecisionForm.from_params(
      customer: customer, decideable: news
    )
  end

  it 'should do nothing when form invalid' do
    expect { command.call(invalid_form, '') }.not_to change(ResolvedItem, :count)
  end

  it 'should do nothing when decision invalid' do
    expect { command.call(valid_form, '') }.not_to change(ResolvedItem, :count)
  end

  it 'should create ResolvedItem with decision' do
    expect { command.call(valid_form, 'rejected') }.to change(ResolvedItem, :count).by(1)
  end
end
