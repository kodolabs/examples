require 'rails_helper'

describe Plans::Create do
  let(:service) { Plans::Create }

  context 'when unpublished' do
    def params(custom = {})
      custom.reverse_merge(
        name: 'Some name',
        stripe_id_monthly: SecureRandom.hex,
        stripe_id_annual: SecureRandom.hex,
        max_accounts: 1
      ).merge(published: false)
    end

    context 'invalid when' do
      it 'name empty' do
        form = Plans::PlanForm.from_params(params(name: ''))
        service.call(form)
        expect(form.valid?).to be_falsey
      end

      it 'name not uniq' do
        form = Plans::PlanForm.from_params(params(name: create(:plan).name))
        service.call(form)
        expect(form.valid?).to be_falsey
      end

      it 'stripe_id empty' do
        %i(stripe_id_monthly stripe_id_annual).each do |attr|
          form = Plans::PlanForm.from_params(params(attr => ''))
          service.call(form)
          expect(form.valid?).to be_falsey
        end
      end

      it 'stripe_id not uniq' do
        plan = create(:plan)
        %i(stripe_id_monthly stripe_id_annual).each do |attr|
          form = Plans::PlanForm.from_params(
            params(attr => plan.send(attr))
          )
          service.call(form)
          expect(form.valid?).to be_falsey
        end
      end
    end

    context 'when name and stripe_id are present and uniq' do
      it 'is valid' do
        form = Plans::PlanForm.from_params(params)
        service.call(form)
        expect(form.valid?).to be_truthy
      end
    end
  end

  context 'when published' do
    def params(custom = {})
      custom.reverse_merge(
        name: 'Some name',
        price_monthly: 9.99,
        price_annual: 99.9,
        stripe_id_monthly: SecureRandom.hex,
        stripe_id_annual: SecureRandom.hex,
        max_accounts: 1
      ).merge(published: true)
    end

    context 'invalid when' do
      it 'name empty' do
        form = Plans::PlanForm.from_params(params(name: ''))
        service.call(form)
        expect(form.valid?).to be_falsey
      end

      it 'name not uniq' do
        form = Plans::PlanForm.from_params(params(name: create(:plan).name))
        service.call(form)
        expect(form.valid?).to be_falsey
      end

      it 'price empty' do
        %i(price_monthly price_annual).each do |attr|
          form = Plans::PlanForm.from_params(params(attr => ''))
          service.call(form)
          expect(form.valid?).to be_falsey
        end
      end

      it 'stripe_id empty' do
        %i(stripe_id_monthly stripe_id_annual).each do |attr|
          form = Plans::PlanForm.from_params(params(attr => ''))
          service.call(form)
          expect(form.valid?).to be_falsey
        end
      end

      it 'stripe_id not uniq' do
        plan = create(:plan)
        %i(stripe_id_monthly stripe_id_annual).each do |attr|
          form = Plans::PlanForm.from_params(
            params(attr => plan.send(attr))
          )
          service.call(form)
          expect(form.valid?).to be_falsey
        end
      end
    end

    context 'when all data correct and uniq' do
      it 'is valid' do
        create(:plan)
        form = Plans::PlanForm.from_params(params)
        service.call(form)
        expect(form.valid?).to be_truthy
      end
    end
  end
end
