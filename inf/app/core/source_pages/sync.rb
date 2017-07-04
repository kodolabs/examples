module SourcePages
  class Sync
    def initialize(options)
      @options = options.try(:with_indifferent_access)
    end

    def call
      form = SourcePages::SourcePageForm.new(@options)
      feed = Feed.find_by(id: @options[:feed_id])
      SourcePages::Create.new(form, feed).call
    end
  end
end
