module Migrations
  class Enum
    def self.host_actions
      { deactivate: 0, empty_blog: 1 }
    end
  end
end
