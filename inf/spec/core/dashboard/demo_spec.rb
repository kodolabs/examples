require 'rails_helper'

describe Dashboard::Demo do
  let(:service) { Dashboard::Demo }
  let(:customer) { create(:customer) }

  specify 'header_data_for' do
    res = service.new(customer).header_data_for('page_likes')
    expect(res[:percentage]).to be_truthy
    expect(res[:total_count]).to be_truthy
  end

  specify 'social_presence_data' do
    res = service.new(customer).social_presence_data
    expect(res[:labels]).to be_truthy
    expect(res[:values]).to be_truthy
  end

  specify 'demographics' do
    res = service.new(customer).demographics
    expect(res.keys.count).to eq(7)
    expect(res.values).to be_truthy
  end

  specify 'locations' do
    res = service.new(customer).locations
    expect(res.keys.count).to eq(4)
    expect(res.values).to be_truthy
  end

  specify 'views' do
    res = service.new(customer).views
    expect(res).to be_truthy
  end
end
