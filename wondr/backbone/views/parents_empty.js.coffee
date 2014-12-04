Wondr.Views.ParentsEmpty = Backbone.Marionette.ItemView.extend

  tagName: 'span'

  render: ->
    @$el.html "<a href='#' class='no_parents'>No parents. Add one?</a>"
    this
