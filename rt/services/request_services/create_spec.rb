require 'rails_helper'

describe RequestServices::Create do
  let(:customer) { create :customer }
  let!(:feedback_template) { create :feedback_template, customer: customer }
  let!(:email_template) { create :email_template, customer: customer }
  let(:location) { create :location, customer: customer }

  let(:valid_params) do
    {
      location_id: location.id,
      feedback_template_id: feedback_template.id,
      sender_name: 'Some name',
      sender_email: 'some@example.com',
      participants: 'some1@example.com,some2@example.com',
      subject: 'Subject',
      send_method: 'email',
      body: 'Some text'
    }
  end

  describe '#call' do
    it 'successfully create user email' do
      expect { RequestServices::Create.new(valid_params, customer).call }.to change { customer.requests.reload.count }.by(1)
    end

    it 'return created user' do
      expect(RequestServices::Create.new(valid_params, customer).call).to be_a Request
    end

    it 'fail while try create user with invalid params' do
      expect { RequestServices::Create.new({}, customer).call }.to_not change { customer.requests.reload.count }
    end

    it 'add call to new requests worker if created success' do
      expect { RequestServices::Create.new(valid_params, customer).call }.to change(SendFeedbackRequestsWorker.jobs, :size).by(1)
    end

    it 'create invitation instances' do
      expect { RequestServices::Create.new(valid_params, customer).call }.to change { RequestInvitation.count }.by(2)
    end

    it 'with invalid new new' do
      invalid_params = valid_params.merge(new_template_name: email_template.name, save_as_new: 1)
      expect { RequestServices::Create.new(invalid_params, customer).call }.to_not change { Request.count }
    end
  end
end
