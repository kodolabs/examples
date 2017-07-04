module Integrations
  module Eventbrite
    class SyncTicketClass < Rectify::Command
      def initialize(webhook_params)
        @ticket_class_url = ticket_class_url(webhook_params)
        @event = get_event(webhook_params)
        @user = @event.creator if @event.present?
      end

      def call
        return unless @event.present?
        ticket_classes = get_ticket_classes(@ticket_class_url, @user)
        sync_ticket_classes(ticket_classes, @event) if ticket_classes
      end

      private

      def get_event(webhook_params)
        event_id = webhook_params[:api_url].split('/').last
        Event.find_by(eventbrite_id: event_id)
      end

      def ticket_class_url(webhook_params)
        webhook_params[:api_url] + 'ticket_classes'
      end

      def get_ticket_classes(ticket_class_url, user)
        token = user.organiser.eventbrite_token
        request_url = ticket_class_url + '/?token=' + token
        request_url = URI(request_url)
        res = Net::HTTP.get(request_url)
        hash = JSON.parse(res)
        return false if hash['status_code'].present?
        hash['ticket_classes']
      end

      def update_ticket_classes(ticket_classes, event)
        ticket_classes.each do |tc|
          begin
            ticket_class = TicketClass.find_or_initialize_by(eventbrite_id: tc['id'])
            ticket_cost = tc['actual_cost'].present? ? tc['actual_cost']['major_value'].to_f : nil
            ticket_class.update_attributes(
              name: tc['name'],
              description: tc['description'],
              quantity_total: tc['quantity_total'],
              sales_start: tc['sales_start'],
              sales_end: tc['sales_end'],
              cost: ticket_cost,
              event: event
            )
          rescue StandardError => e
            Rollbar.error(e)
          end
        end
      end

      def remove_ticket_classes(ticket_classes, event)
        internal_ids = event.ticket_classes.map(&:eventbrite_id)
        external_ids = ticket_classes.map { |tc| tc['id'] }
        async_ids = internal_ids - external_ids
        event.ticket_classes.where(eventbrite_id: async_ids).destroy_all if async_ids.present?
      end

      def sync_ticket_classes(ticket_classes, event)
        update_ticket_classes(ticket_classes, event)
        remove_ticket_classes(ticket_classes, event)
      end
    end
  end
end
