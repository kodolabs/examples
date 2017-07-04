require 'rails_helper'

describe Clients::Create do
  context 'success' do
    let(:user) { create(:user) }
    let(:valid_params) do
      {
        client: {
          name: 'John Doe',
          email: 'johndoe@example.com',
          phone: '+380505550050',
          since: Time.zone.now,
          manager_id: user.id,
          status: 'active'
        }
      }
    end
    let(:client_form) { Clients::ClientForm.from_params(valid_params) }

    specify 'create client' do
      expect { Clients::Create.call(client_form) }.to change(Client, :count).to(1)
    end
  end
end
