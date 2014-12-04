Wondr.Views.Student = Backbone.Marionette.CompositeView.extend

  tagName: 'tr'

  template: JST['backbone/templates/students/student']

  childView: Wondr.Views.Parent

  childViewContainer: 'td.parents p'

  emptyView: Wondr.Views.ParentsEmpty

  events:
    'click .student a': 'edit'

  collectionEvents:
    change: 'render'

  initialize: (options)->
    models = options.parents.filterBy 'id', @model.get('parent_ids')
    @collection = new Wondr.Collections.Parents models

  edit: ->
    Wondr.App.vent.trigger 'student:edit', @model
