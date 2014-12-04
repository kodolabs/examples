Wondr.Views.Teacher = Backbone.Marionette.ItemView.extend

  template: JST['backbone/templates/teachers/teacher']

  tagName: 'span'

  events:
    'click a': 'edit'

  edit: ->
    Wondr.App.vent.trigger 'teacher:edit', @model
