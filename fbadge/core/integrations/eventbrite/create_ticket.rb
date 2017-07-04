module Integrations
  module Eventbrite
    class CreateTicket < Rectify::Command
      require 'eventbrite'

      def initialize(webhook_params)
        @organiser = get_organiser(webhook_params['config']['user_id'])
        @order = get_order(webhook_params['api_url'])
      end

      def call
        return unless @order
        event = get_event(@order['event_id'])
        return unless event
        if Integrations::Eventbrite::ValidateBuyer.new(@order).valid?
          buyer, = Users::FindOrCreate.new(@order['email'], @order['first_name'], @order['last_name']).call
          @order['attendees'].each do |attendee|
            ticket_class = get_ticket_class(attendee['ticket_class_id'])
            next unless ticket_class
            barcode = attendee['barcodes'].first['barcode']
            next if ticket_present?(barcode, ticket_class)
            profile = find_or_create_profile(attendee['profile'], event)
            Tickets::Create.new(profile, ticket_class, barcode, buyer).call
          end
        else
          OrganiserMailer.invalid_buyer(@organiser).deliver_now
        end
      end

      private

      def get_organiser(user_id)
        Organiser.find_by(eventbrite_id: user_id)
      end

      def organiser_token
        @organiser.eventbrite_token if @organiser.present?
      end

      def get_order(api_url)
        request_url = "#{api_url}/?expand=attendees&token=#{organiser_token}"
        request_url = URI(request_url)
        res = Net::HTTP.get(request_url)
        JSON.parse(res)
      rescue
        false
      end

      def get_event(order_id)
        Event.find_by(eventbrite_id: order_id)
      end

      def get_ticket_class(ticket_class_id)
        TicketClass.find_by(eventbrite_id: ticket_class_id)
      end

      def ticket_present?(barcode, ticket_class)
        Ticket.find_by(barcode: barcode, ticket_class_id: ticket_class.id)
      end

      def find_or_create_profile(profile, event)
        Profiles::FindOrCreate.new(profile['email'], profile['first_name'],
          profile['last_name'], profile['company'], profile['job_title'], event).call
      end
    end
  end
end
