require 'rails_helper'

describe Dashboard::NumberClientsProvider do
  let!(:user) { create :user }
  let!(:client1) { create :client, manager: user }
  let!(:client2) { create :client, manager: user, active: false }
  let!(:client3) { create :client, manager: user, active: false }

  let!(:campaign1) { create :campaign, domain: 'google.com', client: client1 }
  let!(:campaign2) { create :campaign, domain: 'amazon.com', client: client2 }
  let!(:campaign3) { create :campaign, domain: 'yahoo', client: client3 }

  before { Rails.cache.clear }

  describe 'Number of clients' do
    it 'should return count of active and inactive clients' do
      clients = Dashboard::NumberClientsProvider.new.call
      assert_equal Client.active.count, clients[:active]
      assert_equal Client.inactive.count, clients[:inactive]
    end

    it 'should recalculate number of clients after active false status' do
      client1.update(active: false)
      clients = Dashboard::NumberClientsProvider.new.call
      assert_equal Client.active.count, clients[:active]
      assert_equal Client.inactive.count, clients[:inactive]
    end
  end
end
