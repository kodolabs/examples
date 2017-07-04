module Webhooks
  module Facebook
    module Page
      class Info
        def initialize(uid)
          @uid = uid
        end

        def call
          id = ::Page.facebook.find_by(uid: @uid).try(:id)
          ::PageWorker.perform_async(id) if id
        end
      end
    end
  end
end
