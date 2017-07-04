require 'rails_helper'

RSpec.describe 'search', type: :routing do
  specify 'show' do
    expect(get('/user/smart-search')).to route_to('user/searches#show')
  end
end
