Wondr.Views.Gallery = Backbone.Marionette.LayoutView.extend

  template: JST['backbone/templates/post']

  id: 'new_gallery'

  sidebarOpen: false

  regions:
    sidebar: '#sidebar'
    content: '#container'

  initialize: (options)->
    @collection = new Wondr.Collections.Uploads @model.get('uploads')
    @klasses = new Wondr.Collections.Klasses

    @listenTo Wondr.App.vent, 'sidebar:open', @toggle_sidebar

  onShow: ->
    @klasses.fetch
      success: (collection)=>
        items = new Wondr.Views.GalleryItems collection: @collection, klasses: collection, mode: 'gallery'
        @content.show(items)

    sidebar = new Wondr.Views.GallerySidebar model: @model, collection: @collection
    @sidebar.show(sidebar)

    @toggle_sidebar() unless @model.isNew()

  validate_collection: ->
    invalid_models = _.filter @collection.models, (model)=>
      model.validate()

    return invalid_models.length == 0

  toggle_sidebar: ->
    if @collection.length > 0 && !@sidebarOpen
      $('.menu-btn').click()
      @sidebarOpen = true


