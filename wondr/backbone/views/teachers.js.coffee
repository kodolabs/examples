Wondr.Views.Teachers = Backbone.Marionette.LayoutView.extend

  id: 'teachers'

  template: JST['backbone/templates/teachers/index']

  events:
    'click .js-add-class':    'klass_add'
    'click .js-add-teacher':  'teacher_add'
    'click .site-overlay':    'close_sidebar'

  regions:
    content: '#content'
    sidebar: '#sidebar'

  initialize: ->
    _.bindAll @, 'close_sidebar', 'klass_edit', 'on_klass_add', 'teacher_edit', 'on_teacher_save'

    @klasses = new Wondr.Collections.Klasses
    @teachers = new Wondr.Collections.Teachers

    @listenTo Wondr.App.vent, 'klass:add', @on_klass_add
    @listenTo Wondr.App.vent, 'klass:edit', @klass_edit
    @listenTo Wondr.App.vent, 'teacher:save', @on_teacher_save
    @listenTo Wondr.App.vent, 'teacher:edit', @teacher_edit
    @listenTo Wondr.App.vent, 'sidebar:close', @close_sidebar

  onShow: ->
    @ensure_teachers_loaded()
    @klasses.fetch
      success: (collection)=>
        view = new Wondr.Views.KlassTeachers collection: collection, teachers: @teachers
        @content.show(view)

  klass_add: ->
    @ensure_teachers_loaded()
    view = new Wondr.Views.KlassForm model: new Wondr.Models.Klass, teachers: @teachers
    @sidebar.show(view)
    @open_sidebar()

  on_klass_add: (model)->
    @klasses.add model

  klass_edit: (model)->
    @ensure_teachers_loaded()
    view = new Wondr.Views.KlassForm model: model, teachers: @teachers
    @sidebar.show(view)
    @open_sidebar()

  teacher_add: ->
    @ensure_teachers_loaded()
    view = new Wondr.Views.TeacherForm model: new Wondr.Models.Teacher
    @sidebar.show(view)
    @open_sidebar()

  on_teacher_save: (model)->
    @teachers.add model, merge: true

  teacher_edit: (model)->
    @ensure_teachers_loaded()
    view = new Wondr.Views.TeacherForm model: model
    @sidebar.show(view)
    @open_sidebar()

  open_sidebar: ->
    $('.menu-btn').trigger('click')

  close_sidebar: ->
    @sidebar.reset()
    $('.menu-btn').trigger('click')

  ensure_teachers_loaded: ->
    @teachers.fetch(async: false) if @teachers.length == 0
