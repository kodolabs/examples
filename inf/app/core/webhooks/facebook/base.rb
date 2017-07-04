module Webhooks
  module Facebook
    class Base
      def initialize(params)
        @params = params
      end

      def call
        return unless @params['object'] == 'page'

        ::Webhooks::Facebook::Page::Base.new(@params['entry']).call
      end
    end
  end
end
