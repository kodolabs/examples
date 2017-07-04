require 'rails_helper'

describe AccountDecorator do
  context 'connected title' do
    specify 'facebook' do
      account = create(:account, :facebook, name: 'Test')
      expect(account.decorate.connected_title).to eq('Connected to Test')
    end

    specify 'twitter' do
      account = create(:account, :twitter, name: 'Test', username: 'test2')
      expect(account.decorate.connected_title).to eq('Connected to Test')
    end
  end
end
