class Badge < ApplicationRecord
  has_one :registration, dependent: :restrict_with_error
end
