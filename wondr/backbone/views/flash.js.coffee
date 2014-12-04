Wondr.Views.Flash = Backbone.View.extend

  initialize: (params)->
    @$el = $("#flash")
    @message = params.message ? ''

  reset: ->
    @$el.html ''

  render: ->
    @$el.html @message
    this
