require 'rails_helper'

describe Organisers::Receptionists::Invite do
  let!(:event) { create :event, :active }
  let!(:receptionist_params) { { name: 'John Doe', email: 'john@doe.com' } }

  before(:each) do
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  context 'when receptionist does not exists' do
    it 'sending invite to receptionist' do
      Receptionists::Create.call(Receptionists::ReceptionistForm.from_params(receptionist_params), event)
      expect(Receptionist.last.name).to eq(receptionist_params[:name])
      expect(Receptionist.last.email).to eq(receptionist_params[:email])
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(ActionMailer::Base.deliveries.first.to).to eq([receptionist_params[:email]])
    end
  end
end
