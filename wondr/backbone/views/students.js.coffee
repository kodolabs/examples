Wondr.Views.Students = Backbone.Marionette.LayoutView.extend

  id: 'students'

  template: JST['backbone/templates/students/index']

  events:
    'click .js-add-student': 'add_student'
    'click .js-add-parent': 'add_parent'
    'click .site-overlay': 'close_sidebar'

  regions:
    sidebar: '#sidebar'
    content: '#content'

  initialize: ->
    _.bindAll @, 'close_sidebar', 'edit_student', 'edit_parent', 'student_saved', 'parent_saved'

    @klasses = new Wondr.Collections.Klasses
    @parents = new Wondr.Collections.Parents

    @listenTo Wondr.App.vent, 'parent:saved', @parent_saved
    @listenTo Wondr.App.vent, 'parent:edit', @edit_parent
    @listenTo Wondr.App.vent, 'student:saved', @student_saved
    @listenTo Wondr.App.vent, 'student:edit', @edit_student
    @listenTo Wondr.App.vent, 'sidebar:close', @close_sidebar

  add_student: ->
    @ensure_parents_loaded()
    view = new Wondr.Views.StudentForm model: new Wondr.Models.Student, parents: @parents, klasses: @klasses
    @sidebar.show(view)
    @open_sidebar()

  edit_student: (model)->
    @ensure_parents_loaded()
    view = new Wondr.Views.StudentForm model: model, parents: @parents, klasses: @klasses
    @sidebar.show(view)
    @open_sidebar()

  student_saved: (model)->
    klass = @klasses.findWhere id: model.get('klass_id')
    klass.get('students').add model, merge: true if klass

  add_parent: ->
    view = new Wondr.Views.ParentForm model: new Wondr.Models.Parent
    @sidebar.show(view)
    @open_sidebar()

  edit_parent: (model)->
    view = new Wondr.Views.ParentForm model: model, title: 'Edit Parent'
    @sidebar.show(view)
    @open_sidebar()

  parent_saved: (model)->
    @parents.add model, merge: true

  open_sidebar: ->
    $('.menu-btn').trigger('click')

  close_sidebar: ->
    @sidebar.reset()
    $('.menu-btn').trigger('click')

  onShow: ->
    @ensure_parents_loaded()
    @klasses.fetch
      success: (collection)=>
        view = new Wondr.Views.Klasses collection: collection, parents: @parents
        @content.show(view)

  ensure_parents_loaded: ->
    @parents.fetch(async: false) if @parents.length == 0
