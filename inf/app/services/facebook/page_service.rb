class Facebook::PageService
  attr_accessor :graph
  def initialize(page)
    @graph = Koala::Facebook::API.new(page.token)
  end
end
