require 'rails_helper'

describe Notifications::Show do
  let(:service) { Notifications::Show }
  let(:channel) { ShareChannel }
  let(:customer) { create(:customer) }
  let(:user) { create(:user, customer: customer) }

  specify 'success' do
    user
    allow(channel).to receive(:broadcast_to)
    options = { type: 'banner', error: true, message: 'error text' }
    expect(channel).to receive(:broadcast_to).once.with(customer.primary_user, options)
    service.new(customer.id, text: 'error text', error: true, type: 'banner').call
  end
end
