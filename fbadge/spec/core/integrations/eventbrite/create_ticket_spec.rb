require 'rails_helper'

describe Integrations::Eventbrite::CreateTicket do
  let!(:user) { create :user, :organiser, email: 'masterdefy@kodolabs.com' }
  let!(:event) { create :event, :active, creator: user, eventbrite_id: '29712155858' }
  let!(:ticket_class) { create :ticket_class, event: event, eventbrite_id: '58136490' }

  before(:each) do
    @order = {
      'email' => 'masterdefy@kodolabs.com',
      'first_name' => 'John',
      'last_name' => 'Doe',
      'event_id' => '29712155858',
      'attendees' => [
        {
          'profile' =>
            {
              'first_name' => 'Kir',
              'last_name' => 'Z',
              'email' => 'masteridefy@gmail.com',
              'name' => 'Kir Z'
            },
          'barcodes' => [
            {
              'barcode' => '574742705722245118001'
            }
          ],
          'ticket_class_id' => '58136490'
        },
        {
          'profile' =>
            {
              'first_name' => 'John',
              'last_name' => 'Doe',
              'email' => 'johndoe@example.com',
              'name' => 'John Doe'
            },
          'barcodes' => [
            {
              'barcode' => '574742705722245119001'
            }
          ],
          'ticket_class_id' => '58136490'
        }
      ]
    }
    @params = { 'config' => { 'user_id' => '1' } }
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  context 'should create buyer and ticket assigned to buyer' do
    specify 'if email of profile blank and buyer is not present' do
      allow_any_instance_of(Integrations::Eventbrite::CreateTicket).to receive(:get_order).and_return(@order)
      @order['email'] = 'someemail@example.com'
      @order['attendees'].last['profile'].delete('email')
      Integrations::Eventbrite::CreateTicket.new(@params).call
      user = User.find_by(email: @order['email'])
      expect(user).to be_present
      expect(Ticket.count).to eq 2
      expect(Ticket.last.buyer_id).to eq user.id
    end
  end

  context 'should create ticket and profile assigned to buyer' do
    specify 'if email of profile blank' do
      @order['attendees'].last['profile'].delete('email')
      allow_any_instance_of(Integrations::Eventbrite::CreateTicket).to receive(:get_order).and_return(@order)
      Integrations::Eventbrite::CreateTicket.new(@params).call
      expect(Profile.count).to eq 2
      expect(Ticket.count).to eq 2
      expect(Ticket.last.buyer_id).to eq user.id
    end

    specify 'if profile already exist create ticket and new profile' do
      allow_any_instance_of(Integrations::Eventbrite::CreateTicket).to receive(:get_order).and_return(@order)
      @order['attendees'].last['profile']['email'] = 'masteridefy@gmail.com'
      Integrations::Eventbrite::CreateTicket.new(@params).call
      expect(Profile.count).to eq 2
      expect(Ticket.count).to eq 2
      expect(Ticket.last.buyer_id).to eq user.id
    end
  end

  context 'should create user and profile' do
    specify 'with ticket' do
      allow_any_instance_of(Integrations::Eventbrite::CreateTicket).to receive(:get_order).and_return(@order)
      Integrations::Eventbrite::CreateTicket.new(@params).call
      expect(User.count).to eq 3
      expect(Profile.count).to eq 2
      expect(Ticket.count).to eq 2
    end
  end

  context 'should create user, profile and ticket' do
    specify 'and send email to existing user' do
      allow_any_instance_of(Integrations::Eventbrite::CreateTicket).to receive(:get_order).and_return(@order)
      create(:user, email: 'masteridefy@gmail.com')
      expect(User.count).to eq 2
      Integrations::Eventbrite::CreateTicket.new(@params).call
      expect(User.count).to eq 3
      expect(Profile.count).to eq 2
      expect(Ticket.count).to eq 2
      expect(ActionMailer::Base.deliveries.first.subject).to eq(I18n.t('email.subjects.new_profile'))
    end
  end

  context 'should send email to organiser' do
    specify 'if buyer attributes is not valid' do
      user.organiser.update_attribute(:eventbrite_id, '1')
      @order.delete('email')
      allow_any_instance_of(Integrations::Eventbrite::CreateTicket).to receive(:get_order).and_return(@order)
      Integrations::Eventbrite::CreateTicket.new(@params).call
      expect(ActionMailer::Base.deliveries.first.subject).to eq(I18n.t('email.subjects.invalid_buyer'))
    end
  end
end
