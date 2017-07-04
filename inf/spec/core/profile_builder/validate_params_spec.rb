require 'rails_helper'

describe ProfileBuilder::ValidateParams do
  let(:command) { ProfileBuilder::ValidateParams }
  let(:form) { ProfileBuilder::Form }
  context 'phone number' do
    specify 'success' do
      f = form.from_params(contact_number: '123')
      expect { command.new(f, ['contact_number']).call }.to broadcast(:invalid)
    end

    specify 'fail' do
      f = form.from_params(contact_number: '+12312312311')
      expect { command.new(f, ['contact_number']).call }.to broadcast(:ok)
    end
  end
end
