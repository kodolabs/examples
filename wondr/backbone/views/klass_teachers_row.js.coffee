Wondr.Views.KlassTeachersRow = Backbone.Marionette.CompositeView.extend

  template: JST['backbone/templates/teachers/row']

  tagName: 'tr'

  childView: Wondr.Views.Teacher

  emptyView: Wondr.Views.TeachersEmpty

  childViewContainer: 'td.teachers p'

  events:
    'click .klass a': 'edit'

  collectionEvents:
    change: 'render'

  initialize: (options)->
    @teachers = options.teachers
    @update_collection()

  templateHelpers:
    student_count: ->
      @students.length

  edit: ->
    Wondr.App.vent.trigger 'klass:edit', @model

  onBeforeRender: ->
    @update_collection()

  update_collection: ->
    models = @teachers.filterBy 'id', @model.get('admin_ids')
    @collection = new Wondr.Collections.Teachers models
