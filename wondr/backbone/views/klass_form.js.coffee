Wondr.Views.KlassForm = Backbone.Marionette.ItemView.extend

  template: JST['backbone/templates/teachers/klass_form']

  events:
    'submit form': 'submit'
    'click .close': 'close_form'
    'click .delete': 'delete'

  bindings:
    '#name': 'name'
    '#location': 'location'
    '#year': 'year'
    '#admin_ids':
      observe: 'admin_ids'
      selectOptions:
        collection: 'this.teachers'
        labelPath: 'full_name'
        valuePath: 'id'

  initialize: (params)->
    _.bindAll @, 'on_success', 'on_error'
    @model.set 'title', if @model.isNew() then 'New Class' else 'Edit Class'
    @teachers = params.teachers

  submit: (e)->
    e.preventDefault()

    res = @model.save {},
      success: @on_success
      error: @on_error

  onRender: ->
    @stickit()

    @$('.tags').chosen()
    @$('.delete').hide() if @model.get('id') == undefined

    Backbone.Validation.bind @,
      valid: @valid
      invalid: @invalid

    this

  on_success: (model)->
    Wondr.App.vent.trigger 'klass:add', model
    @close_form()

  on_error: (model, xhr)->
    errors = Helper.object_to_string xhr.responseJSON.errors
    @$el.find('.form-errors').html(errors)

  close_form: ->
    Wondr.App.vent.trigger('sidebar:close')

  valid: (view, attr)->
    target = view.$el.find("#" + attr).closest('div')
    target.data('tip').deactivate() if target.data('tip')

  invalid: (view, attr, error)->
    target = view.$el.find("#" + attr).closest('div')
    target.data('tip').deactivate() if target.data('tip')
    tip = target.opentip(error, {target: target, style: 'alert', tipJoint: 'middle right', showOn: 'creation'})
    target.data('tip', tip)

  delete: ->
    if confirm 'Are you sure you want to delete this class'
      @model.destroy
        success: @close_form

