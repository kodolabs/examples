require 'rails_helper'

describe Events::CreateData do
  let(:user) { create :user, :organiser }
  let(:event) { create :event, :active }
  let(:profile) { create :profile, user: user, event: event }
  let(:call) { Events::CreateData.call(event, user) }

  specify 'create new profile' do
    expect { call }.to change(Profile, :count).by(1)
  end

  specify 'create new location' do
    expect { call }.to change(Location, :count).by(1)
  end

  specify 'create new slot' do
    expect { call }.to change(Location, :count).by(1)
  end
end
