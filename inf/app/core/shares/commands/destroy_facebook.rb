module Shares
  module Commands
    class DestroyFacebook
      def initialize(publication)
        @publication = publication
      end

      def call
        graph.delete_object(@publication.uid)['success']
      rescue Koala::Facebook::ClientError
        return false
      end

      private

      def graph
        @graph ||= Koala::Facebook::API.new(token)
      end

      def token
        @token ||= @publication.owned_page.token
      end
    end
  end
end
