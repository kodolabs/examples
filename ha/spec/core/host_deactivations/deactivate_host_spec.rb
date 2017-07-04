require 'rails_helper'

describe HostDeactivations::Deactivate do
  let!(:domain) { create :domain, name: 'google.com', status: :active }
  let!(:blog) { create :blog }
  let!(:host) { create :host, domain: domain, blog: blog, active: true }
  let!(:valid_params) do
    {
      status: 'pending',
      reason: 'Reason'
    }
  end
  let!(:host_deactivation_form) { HostDeactivations::HostDeactivationForm.from_params(valid_params) }

  describe '.call' do
    context 'success deactivate host' do
      it 'should update host with inactive status' do
        HostDeactivations::Deactivate.call(domain, host_deactivation_form)
        domain.reload
        host.reload
        expect(domain.host).to eq nil
        expect(host.active).to be_falsey
        expect(domain.status).to eq 'pending'
      end
    end
  end
end
