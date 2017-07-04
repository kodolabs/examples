class Facebook::SavePageInfo
  def initialize(page)
    @page = page
  end

  def call
    return if @page.blank?
    graph = Facebook::Service.new.graph
    return if graph.blank?
    data = graph.get_object(@page.api_handle, fields: %w(description name cover picture.type(normal) about))

    @page.attributes = attributes_for(data)
    @page.save if @page.changed?
  rescue Koala::Facebook::ClientError
    return false
  rescue => error
    Rollbar.error(error)
  end

  private

  def attributes_for(data)
    {
      logo:  data.try(:[], 'picture').try(:[], 'data').try(:[], 'url'),
      background_image: data.try(:[], 'cover').try(:[], 'source'),
      title: data['name'],
      description: data['about']
    }
  end
end
