module Verificable
  extend ActiveSupport::Concern

  included do
    enum status: { pending: 0, approved: 1, declined: 2 }
  end
end
