module SourcePages
  class Destroy < Rectify::Command
    def initialize(source_page)
      @source_page = source_page
    end

    def call
      return broadcast(:ok) if @source_page.destroy
      broadcast(:invalid)
    end
  end
end
