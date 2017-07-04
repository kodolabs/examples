require 'rails_helper'

describe Clients::Update do
  context 'success' do
    let(:user) { create(:user) }
    let(:client) { create(:client, name: 'John Doen', email: 'johndoe@gmail.com') }
    let(:valid_params) do
      {
        client: {
          name: 'Jack Smith',
          email: 'jacksmith@example.com',
          phone: '+380505550050',
          since: Time.zone.now,
          manager_id: user.id,
          status: 'active'
        }
      }
    end
    let(:client_form) { Clients::ClientForm.from_params(valid_params) }

    specify 'update client' do
      Clients::Update.call(client_form, client)
      client.reload
      expect(client.name).to eq 'Jack Smith'
      expect(client.email).to eq 'jacksmith@example.com'
    end
  end
end
