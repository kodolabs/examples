module Periodable
  extend ActiveSupport::Concern

  included do
    enum period: { day: 0, week: 1, days_28: 2, lifetime: 3 }
  end
end
