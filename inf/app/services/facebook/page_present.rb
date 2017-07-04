class Facebook::PagePresent
  def initialize(handle)
    @handle = handle
  end

  def call
    facebook = Facebook::Service.new
    facebook.page_present?(@handle)
  rescue => error
    Rollbar.error(error)
    false
  end
end
