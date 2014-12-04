Wondr.Views.Klass = Backbone.Marionette.CompositeView.extend

  childView: Wondr.Views.Student

  childViewContainer: 'tbody'

  emptyView: Wondr.Views.NoStudents

  tagName: 'section'

  className: 'class'

  template: JST['backbone/templates/students/klass']

  events:
    'click .js-sort:not(.disable)': 'rearrange'

  collectionEvents:
    change: 'render'
    add: 'thead_visibility'
    sort: 'render'

  initialize: (options)->
    @parents = options.parents ? []
    @collection = @model.get('students')

  childViewOptions: ->
    parents: @parents

  rearrange: (e)->
    e.preventDefault()

    association_name = $(e.target).closest('th').data('model')
    association_name = if association_name == 'student' then null else association_name

    direction = $(e.target).data('direction')

    @collection.comparator = (a, b)->
      (new Wondr.Services.Comparator()).name_comparator(a, b, direction, association_name)

    @collection.sort()

  onRender: ->
    @thead_visibility()

  thead_visibility: ->
    @$el.find('thead').hide() if @collection.length == 0
    @$el.find('thead').show() if @collection.length > 0
