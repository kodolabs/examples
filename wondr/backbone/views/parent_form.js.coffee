Wondr.Views.ParentForm = Backbone.Marionette.ItemView.extend

  template: JST['backbone/templates/students/parent_form']

  events:
    'submit form':          'submit'
    'click .save':          'save'
    'click .save_another':  'save_another'
    'click .close':         'close_form'
    'click .delete':        'delete'

  bindings:
    '#first_name': 'first_name'
    '#last_name': 'last_name'
    '#email': 'email'

  initialize: (params)->
    _.bindAll @, 'on_success', 'on_error'
    @model.set 'title', if @model.isNew() then 'New Parent' else 'Edit Parent'

  save: ->
    @close_on_save = true

  save_another: (e)->
    @close_on_save = false
    true # need to return TRUE otherwise form will not be submitted

  submit: (e)->
    e.preventDefault()

    @model.save {},
      success: @on_success
      error: @on_error

  on_success: (model)->
    Wondr.App.vent.trigger 'parent:saved', model
    if @close_on_save
      @close_form()
    else
      @clear_form()

  clear_form: ->
    @model = new Wondr.Models.Parent title: 'New Parent'
    @render()

  on_error: (model, xhr)->
    errors = Helper.object_to_string xhr.responseJSON.errors
    @$el.find('.form-errors').html(errors)

  onRender: ->
    @stickit()

    @$el.find('.tags').chosen()

    @$('.delete').hide() if @model.get('id') == undefined

    Backbone.Validation.bind @,
      valid: @valid
      invalid: @invalid

    this

  valid: (view, attr)->
    target = view.$el.find("#" + attr).closest('div')
    target.data('tip').deactivate() if target.data('tip')


  invalid: (view, attr, error)->
    target = view.$el.find("#" + attr).closest('div')
    target.data('tip').deactivate() if target.data('tip')
    tip = target.opentip(error, {target: target, style: 'alert', tipJoint: 'middle left', showOn: 'creation'})
    target.data('tip', tip)

  delete: ->
    if confirm 'Are you sure you want to delete parent?'
      @model.destroy
        success: @close_form

  close_form: ->
    Wondr.App.vent.trigger('sidebar:close')


