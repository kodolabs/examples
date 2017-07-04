module NewsItems
  class Blacklist
    def initialize(q)
      @q = q
    end

    def call
      return if @q.blank?
      create_keyword
      destroy
    end

    private

    def create_keyword
      BannedKeyword.find_or_create_by(keyword: @q.strip)
    end

    def destroy
      News.search(@q).destroy_all
    end
  end
end
