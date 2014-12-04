Wondr.Views.TeacherForm = Backbone.Marionette.ItemView.extend

  template: JST['backbone/templates/teachers/teacher_form']

  events:
    'submit form': 'submit'
    'click .close': 'close_form'
    'click .delete': 'delete'

  bindings:
    '#first_name': 'first_name'
    '#last_name': 'last_name'
    '#email': 'email'

  initialize: (params)->
    _.bindAll @, 'on_success', 'on_error'
    @model.set 'title', if @model.isNew() then 'New Teacher' else 'Edit Teacher'

  submit: (e)->
    e.preventDefault()

    @model.save {},
      success: @on_success
      error: @on_error

  delete: ->
    if confirm 'Are you sure you want to delete this teacher record?'
      @model.destroy
        success: @close_form

  close_form: ->
    Wondr.App.vent.trigger('sidebar:close')

  on_success: (model)->
    Wondr.App.vent.trigger 'teacher:save', model
    @close_form()

  on_error: (model, xhr)->
    errors = Helper.object_to_string xhr.responseJSON.errors
    @$el.find('.form-errors').html(errors)

  onRender: ->
    @$('.delete').hide() if @model.get('id') == undefined

    Backbone.Validation.bind @,
      valid: @valid
      invalid: @invalid

    @stickit()
    this

  valid: (view, attr)->
    target = view.$el.find("#" + attr).closest('div')
    target.data('tip').deactivate() if target.data('tip')

  invalid: (view, attr, error)->
    target = view.$el.find("#" + attr).closest('div')
    target.data('tip').deactivate() if target.data('tip')
    tip = target.opentip(error, {target: target, style: 'alert', tipJoint: 'middle left', showOn: 'creation'})
    target.data('tip', tip)
