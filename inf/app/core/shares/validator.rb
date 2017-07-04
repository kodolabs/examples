module Shares
  class Validator < ActiveModel::Validator
    include ::Schedule::BaseValidator

    def validate(record)
      validate_targets_presence(record)
      validate_future_date_time(record)
    end
  end
end
