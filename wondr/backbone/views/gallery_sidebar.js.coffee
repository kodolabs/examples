Wondr.Views.GallerySidebar = Wondr.Views.Sidebar.extend

  template: JST['backbone/templates/gallery/sidebar']

  bindings:
    '#name': 'name'
    '#description': 'description'

  onShow: ->
    @$('.tags').chosen()
    @$('.tab-links li:first-child a').trigger('click')

    @render_outcomes()

    Backbone.Validation.bind @,
      valid: @valid
      invalid: @invalid

    @stickit()

  submit: (e)->
    e.preventDefault()

    @model.set 'uploads_data', @collection.prepare_for_submit()

    @model.save {},
      success: @on_success
      error: @on_error

  render_outcomes: ->
    outcomes = new Wondr.Collections.Outcomes
    outcomes.fetch
      success: (collection)->
        view = new Wondr.Views.Outcomes collection: collection
        $("#outcomes").append(view.render().el)

