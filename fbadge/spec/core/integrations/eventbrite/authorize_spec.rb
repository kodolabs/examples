require 'rails_helper'

describe Integrations::Eventbrite::Authorize do
  let!(:user) { create :user, :organiser }

  it 'should return and update token for organiser' do
    auth_data = { credentials: { token: 'M32LSQD3N65ERJWFNHU4', expires: false }, extra: { raw_info: { id: '123' } } }
    Integrations::Eventbrite::Authorize.call(user, auth_data)
    expect(user.organiser.eventbrite_token).to eq(auth_data[:credentials][:token])
    expect(user.organiser.eventbrite_id).to eq(auth_data[:extra][:raw_info][:id])
  end

  it 'should return invalid status if credentials are blank' do
    auth_data = { extra: { raw_info: { id: '123' } } }
    Integrations::Eventbrite::Authorize.call(user, auth_data)
    expect(user.organiser.eventbrite_token).to eq(nil)
    expect(user.organiser.eventbrite_id).to eq(nil)
  end

  it 'should return invalid status if credentials are expired' do
    auth_data = { credentials: { token: 'M32LSQD3N65ERJWFNHU4', expires: true }, extra: { raw_info: { id: '123' } } }
    Integrations::Eventbrite::Authorize.call(user, auth_data)
    expect(user.organiser.eventbrite_token).to eq(nil)
    expect(user.organiser.eventbrite_id).to eq(nil)
  end
end
