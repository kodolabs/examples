Wondr.Views.Parent = Backbone.Marionette.ItemView.extend

  template: JST['backbone/templates/students/parent']

  tagName: 'span'

  events:
    'click a': 'edit'

  edit: ->
    Wondr.App.vent.trigger 'parent:edit', @model
