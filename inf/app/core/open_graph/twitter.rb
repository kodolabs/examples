module OpenGraph
  class Twitter < Base
    private

    def parse_tag(title, _options = {})
      super(title, { prefix: :twitter }) || super(title)
    end
  end
end
