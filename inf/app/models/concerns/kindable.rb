module Kindable
  extend ActiveSupport::Concern

  included do
    enum kind: { news: 0, research: 1 }
  end
end
