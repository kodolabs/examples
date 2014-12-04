Wondr.Views.Quote = Backbone.Marionette.LayoutView.extend

  template: JST['backbone/templates/post']

  id: 'new_quote'

  regions:
    sidebar: '#sidebar'
    content: '#container'

  initialize: (options)->
    @klasses = new Wondr.Collections.Klasses
    @collection = new Wondr.Collections.Uploads @model.get('uploads')

  onShow: ->
    @klasses.fetch
      success: (collection)=>
        items = new Wondr.Views.GalleryItems collection: @collection, klasses: collection, mode: 'quote'
        @content.show(items)

        sidebar = new Wondr.Views.QuoteSidebar model: @model, collection: @collection, klasses: collection
        @sidebar.show(sidebar)

    @open_sidebar()

  validate_collection: ->
    invalid_models = _.filter @collection.models, (model)=>
      model.validate()

    return invalid_models.length == 0

  open_sidebar: ->
    $('.menu-btn').click()


