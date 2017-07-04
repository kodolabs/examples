module Integrations
  module Eventbrite
    class ValidateBuyer < Rectify::Command
      def initialize(order)
        @order = order
      end

      def valid?
        @order['email'].present? && @order['first_name'].present? && @order['last_name'].present?
      end
    end
  end
end
