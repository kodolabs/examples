require 'rails_helper'

describe ResolvedItems::DecisionForm do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:news) { create(:news) }
  let(:form) { ResolvedItems::DecisionForm }

  describe 'validation' do
    it 'validates presence of customer and news' do
      expect(form.from_params(news: news).valid?).to be_falsey
      expect(form.from_params(customer: customer).valid?).to be_falsey
    end

    it 'validates uniqueness of customer and news' do
      expect(form.from_params(customer: customer, decideable: news).valid?).to be_truthy
      ResolvedItem.create(customer: customer, decideable: news)
      expect(form.from_params(customer: customer, decideable: news).valid?).to be_falsey
    end
  end
end
