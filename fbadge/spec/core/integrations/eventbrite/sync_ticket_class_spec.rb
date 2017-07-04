require 'rails_helper'

describe Integrations::Eventbrite::SyncTicketClass do
  let(:params) { ActionController::Parameters.new('api_url' => 'https://www.eventbriteapi.com/v3/events/26898301544/') }
  let!(:event) { create :event, :active, eventbrite_id: '26898301544' }

  context 'when ticket class not exist' do
    specify 'create new ticket class' do
      data = [{
        'resource_uri' => 'https://www.eventbriteapi.com/v3/events/26898301544/ticket_classes/53051603/',
        'name' => 'Free',
        'description' => nil,
        'quantity_total' => 10,
        'sales_start' => '2016-08-02T02:35:00Z',
        'sales_end' => '2016-08-14T11:17:13Z'
      }]
      allow_any_instance_of(Integrations::Eventbrite::SyncTicketClass).to receive(:get_ticket_classes).and_return(data)
      expect { Integrations::Eventbrite::SyncTicketClass.call(params) }.to change(TicketClass, :count).by(1)
    end
  end

  context 'when ticket class exist' do
    before do
      create :ticket_class, event: event, quantity_total: 5, eventbrite_id: '123'
    end

    specify 'update ticket class attributes' do
      data = [{
        'resource_uri' => 'https://www.eventbriteapi.com/v3/events/26898301544/ticket_classes/53051603/',
        'name' => 'Free',
        'description' => 'Some description',
        'quantity_total' => 10,
        'sales_start' => '2016-08-02T02:35:00Z',
        'sales_end' => '2016-08-14T11:17:13Z',
        'id' => '123'
      }]
      allow_any_instance_of(Integrations::Eventbrite::SyncTicketClass).to receive(:get_ticket_classes).and_return(data)
      Integrations::Eventbrite::SyncTicketClass.call(params)
      expect(TicketClass.first.quantity_total.to_i).to eq(10)
      expect(TicketClass.first.description).to eq('Some description')
    end

    specify 'delete async ticket class' do
      expect(TicketClass.count).to eq(1)
      data = []
      allow_any_instance_of(Integrations::Eventbrite::SyncTicketClass).to receive(:get_ticket_classes).and_return(data)
      Integrations::Eventbrite::SyncTicketClass.call(params)
      expect(TicketClass.count).to eq(0)
    end
  end
end
