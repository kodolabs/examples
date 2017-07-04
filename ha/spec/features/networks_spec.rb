require 'rails_helper'

feature 'Networks page' do
  let!(:network1) { create :network, title: 'Epic 1' }
  let!(:network2) { create :network, title: 'Epic 2' }
  let!(:network3) { create :network, title: 'Epic C' }

  let!(:domain1) { create :domain, network: network1, status: :active, index_status: :indexed }
  let!(:domain2) { create :domain, network: network1, status: :active }
  let!(:domain3) { create :domain, network: network2, status: :active, index_status: :indexed }
  let!(:domain4) { create :domain, network: network2, status: :active, index_status: :not_indexed }
  let!(:domain5) { create :domain, network: network3, status: :active, index_status: :indexed }
  let!(:domain6) { create :domain, network: network3, status: :inactive, index_status: :indexed }
  let!(:domain7) { create :domain, network: nil, status: :active, index_status: :indexed }
  let!(:domain8) { create :domain, network: nil, status: :active, index_status: :not_indexed }
  let!(:domain9) { create :domain, network: network1, status: :pending, index_status: :indexed }
  let!(:domain10) { create :domain, network: network2, status: :pending, index_status: :not_indexed }

  before do
    user_sign_in
    visit networks_path
    @networks = page.all('.network')
  end

  describe 'list' do
    it 'should show count of domains' do
      expect(@networks[0].find('td:nth-child(3)')).to have_content '3'
      expect(@networks[0].find('td:nth-child(4)')).to have_content '2'
      expect(@networks[0].find('td:nth-child(5)')).to have_content '0'
      expect(@networks[0].find('td:nth-child(6)')).to have_content '1'

      expect(@networks[1].find('td:nth-child(3)')).to have_content '3'
      expect(@networks[1].find('td:nth-child(4)')).to have_content '1'
      expect(@networks[1].find('td:nth-child(5)')).to have_content '2'
      expect(@networks[1].find('td:nth-child(6)')).to have_content '1'

      expect(@networks[2].find('td:nth-child(3)')).to have_content '1'
      expect(@networks[2].find('td:nth-child(4)')).to have_content '1'
      expect(@networks[2].find('td:nth-child(5)')).to have_content '0'
      expect(@networks[2].find('td:nth-child(6)')).to have_content '0'

      expect(@networks[3].find('td:nth-child(3)')).to have_content '2'
      expect(@networks[3].find('td:nth-child(4)')).to have_content '1'
      expect(@networks[3].find('td:nth-child(5)')).to have_content '1'
      expect(@networks[3].find('td:nth-child(6)')).to have_content '0'

      expect(@networks[4].find('th:nth-child(3)')).to have_content '9'
      expect(@networks[4].find('th:nth-child(4)')).to have_content '5'
      expect(@networks[4].find('th:nth-child(5)')).to have_content '3'
      expect(@networks[4].find('th:nth-child(6)')).to have_content '2'
    end
  end
end
