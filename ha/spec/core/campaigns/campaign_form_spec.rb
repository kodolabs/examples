require 'rails_helper'

describe Campaigns::CampaignForm do
  context 'validation' do
    let!(:form) { Campaigns::CampaignForm }
    let(:params) do
      {
        domain: 'www.example.com',
        network_ids: ['', '2', '3'],
        seo: '1',
        seo_amount: '100',
        ppc: '0',
        ppc_amount: '',
        social: '1',
        social_amount: '150',
        contract_period: '24',
        brand: 'resolve',
        started_at: '10/09/2017'
      }
    end

    it 'valid with valid params' do
      expect(form.from_params(params).valid?).to be_truthy
    end

    it 'networks presence' do
      params[:network_ids] = ['']
      f = form.from_params(params)
      expect(f.valid?).to be_falsey
      expect(f.errors.keys.include?(:network_ids))
    end

    it 'service blank' do
      params[:seo] = '0'
      params[:ppc] = '0'
      params[:social] = '0'
      f = form.from_params(params)
      expect(f.valid?).to be_falsey
      expect(f.errors.keys.include?([:seo, :ppc, :social]))
    end

    it 'services amount blank' do
      params[:seo] = '1'
      params[:ppc] = '1'
      params[:social] = '0'
      f = form.from_params(params)
      expect(f.valid?).to be_falsey
      expect(f.errors.keys.include?([:seo_amount, :ppc_amount]))
    end
  end
end
