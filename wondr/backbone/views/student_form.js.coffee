Wondr.Views.StudentForm = Backbone.Marionette.ItemView.extend

  template: JST['backbone/templates/students/student_form']

  events:
    'submit form':          'submit'
    'click .save':          'save'
    'click .save_another':  'save_another'
    'click .close':         'close_form'
    'click .delete':        'delete'

  bindings:
    '#first_name': 'first_name'
    '#last_name': 'last_name'
    '#dob':
      observe: 'dob' # moment($('#dob').val(), 'DD/MM/YYYY').format('YYYY-MM-DD')
      onGet: 'human_date'
    '#id_number': 'id_number'
    '#klass_id':
      observe: 'klass_id'
      selectOptions:
        collection: 'this.klasses'
        valuePath: 'id'
        labelPath: 'name'
        defaultOption:
          label: 'Choose a class'
          value: null
    '#parent_ids':
      observe: 'parent_ids'
      selectOptions:
        collection: 'this.parents'
        valuePath: 'id'
        labelPath: 'full_name'

  initialize: (options)->
    _.bindAll @, 'on_success', 'on_error', 'close_view', 'init_avatar_sender', 'add_upload_icon', 'update_model'
    @model.set 'title', if @model.isNew() then 'New Student' else 'Edit Student'
    @klasses = options.klasses
    @parents = options.parents

  human_date: (value, options) ->
    moment(new Date(value)).format('DD/MM/YYYY') if value?

  save: ->
    @close_on_save = true

  save_another: (e)->
    @close_on_save = false
    true # need to return TRUE otherwise form will not be submitted

  onRender: ->
    @stickit()

    @$('.tags').chosen()

    @$('.delete').hide() if @model.get('id') == undefined

    @$('#dob').datepicker
      format: 'dd/mm/yyyy'
      startView: 'decade'
      minViewMode: 0
      endDate: new Date
      autoclose: true

    Backbone.Validation.bind @,
      valid: @valid
      invalid: @invalid

    this

  submit: (e)->
    e.preventDefault()

    @model.save {},
      success: @on_success
      error: @on_error
    @listenTo Wondr.App.vent, 'student:avatar:updated', @close_view, @

  delete: ->
    if confirm 'Are you sure you want to delete this student record?'
      @model.destroy
        success: @close_form

  close_form: ->
    Wondr.App.vent.trigger('sidebar:close')

  clear_form: ->
    @model = new Wondr.Models.Student title: 'New Student'
    @render()

  on_success: (model)->
    Wondr.App.vent.trigger 'student:saved', model
    unless @fileupload_sender
      Wondr.App.vent.trigger 'student:avatar:updated'

  close_view: ->
    if @close_on_save
      @close_form()
    else
      @clear_form()

  on_error: (model, xhr)->
    errors = Helper.object_to_string xhr.responseJSON.errors
    @$el.find('.form-errors').html(errors)

  valid: (view, attr)->
    target = view.$el.find("#" + attr).closest('div')
    target.data('tip').deactivate() if target.data('tip')

  invalid: (view, attr, error)->
    target = view.$el.find("#" + attr).closest('div')
    target.data('tip').deactivate() if target.data('tip')
    tip = target.opentip(error, {target: target, style: 'alert', tipJoint: 'middle right', showOn: 'creation'})
    target.data('tip', tip)

  init_fileupload: ->
    @fileupload_sender = null

    @$el.find('#fileupload').fileupload
      dataType: 'json'
      method: 'put'
      paramName: 'student[avatar]'
      replaceFileInput: false
      autoUpload: false
    .on 'fileuploadadd', @init_avatar_sender
    .on 'fileuploadsubmit', @add_upload_icon
    .on 'fileuploaddone', @update_model
    .on 'fileuploadchange', @remove_sender

  init_avatar_sender: (e, data) ->
    @stopListening @model, 'sync', @fileupload_sender if @fileupload_sender
    @fileupload_sender = ->
      data.url = @model.url()
      data.submit()
    @listenToOnce @model,'sync', @fileupload_sender

  add_upload_icon: (e, data) ->
    @model.set(avatar_thumb: '/assets/icon_processing.gif')

  update_model: (e, data) ->
    result = data.result
    if result.id?
      @model.set(result)
    Wondr.App.vent.trigger 'student:avatar:updated'

  remove_sender: (e, data) ->
    @fileupload_sender = null
