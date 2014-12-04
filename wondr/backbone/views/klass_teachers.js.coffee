Wondr.Views.KlassTeachers = Backbone.Marionette.CompositeView.extend

  template: JST['backbone/templates/teachers/table']

  childView: Wondr.Views.KlassTeachersRow

  childViewContainer: 'tbody'

  emptyView: Wondr.Views.KlassesEmpty

  collectionEvents:
    change: 'render'
    add: 'toggle_thead_visibility'
    remove: 'toggle_thead_visibility'


  initialize: (options)->
    @teachers = options.teachers

  childViewOptions: ->
    teachers: @teachers

  onRender: ->
    @toggle_thead_visibility()

  toggle_thead_visibility: ->
    if @collection.length == 0 then @$('thead').hide() else @$('thead').show()
