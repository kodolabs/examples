Wondr.Routers.Router = Backbone.Marionette.AppRouter.extend

  routes:
    '':             'home'
    'timeline':     'home'
    'new':          'new'
    'new_quote':    'new_quote'
    'new_gallery':  'new_gallery'
    'post/:id':     'post'
    'students':     'students'
    'teachers':     'teachers'

  router_map:
    'home':         'timeline'
    'post':         'timeline'
    'new':          'new'
    'new_gallery':  'new'
    'new_quote':    'new'
    'students':     'students'
    'teachers':     'teachers'

  initialize: ->
    _.bindAll @, 'on_new_post', 'on_flash', 'on_route'

    @push_state_init()
    @init_events()

    @posts = new Wondr.Collections.Posts
    @klasses = new Wondr.Collections.Klasses

    @header = new Wondr.Views.Header
    @header.init()
    @on 'route', @on_route

  before: ->
    @reset_flash()

    if $('#sidebar.pushy-open').length > 0
      $('.menu-btn').trigger('click')
      $('header').removeClass('push-push')

  on_route: (route, params) ->
    @header.update_state(@router_map[route])

  home: ->
    @ensure_collection_loaded(@posts)

    view = new Wondr.Views.Timeline collection: @posts
    Wondr.App.main.show(view)

  new: ->
    view = new Wondr.Views.New
    Wondr.App.main.show(view)

  new_gallery: ->
    @ensure_collection_loaded(@posts)

    view = new Wondr.Views.Gallery model: new Wondr.Models.Gallery
    Wondr.App.main.show(view)

  new_quote: ->
    view = new Wondr.Views.Quote model: new Wondr.Models.Quote
    Wondr.App.main.show(view)

  post: (id)->
    @ensure_collection_loaded(@posts)
    model = @posts.get id

    if model.isGallery()
      view = new Wondr.Views.Gallery model: model
    else
      view = new Wondr.Views.Quote model: model

    Wondr.App.main.show(view)

  students: ->
    view = new Wondr.Views.Students
    Wondr.App.main.show(view)


  teachers: ->
    view = new Wondr.Views.Teachers
    Wondr.App.main.show(view)

  # private methods

  push_state_init: ->
    $(document).on 'click', "a[href^='/']", (e)->
      href = $(e.currentTarget).attr('href')

      # chain 'or's for other black list routes
      passThrough = href.indexOf('sign_out') >= 0

      # Allow shift+click for new tabs, etc.
      if !passThrough && !e.altKey && !e.ctrlKey && !e.metaKey && !e.shiftKey
        e.preventDefault()

        # Remove leading slashes and hash bangs (backward compatablility)
        url = href.replace(/^\//,'').replace('\#\!\/','')

        # Instruct Backbone to trigger routing events
        Wondr.App.router.navigate url, trigger: true
        false

  init_events: ->
    vent = Backbone.Wreqr.radio.channel('global').vent
    vent.on 'flash', @on_flash
    vent.on 'post:new', @on_new_post

  on_new_post: (model)->
    @posts.add model, at: 0

  on_flash: (e)->
    view = new Wondr.Views.Flash message: e
    view.render()

  reset_flash: ->
    Wondr.App.vent.trigger 'flash', ''

  ensure_collection_loaded: (collection)->
    # only fetch galleries on first load - new galleries will be added internally
    collection.fetch async: false unless collection.length > 0
