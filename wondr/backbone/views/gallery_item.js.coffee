Wondr.Views.GalleryItem = Backbone.Marionette.ItemView.extend

  className: 'item'

  template_gallery: JST['backbone/templates/gallery/item']
  template_quote: JST['backbone/templates/quote/item']

  bindings:
    '.students': 'student_ids'
    '.description': 'description'
    '.student_ids':
      observe: 'student_ids'
      selectOptions:
        collection: ->
          res = opt_labels: []
          _.each @klasses.models, (klass)->
            res.opt_labels.push klass.get('name')
            res[klass.get('name')] = []
            _.each klass.get('students').models, (student)->
              res[klass.get('name')].push id: student.get('id'), full_name: student.get('full_name')
          res

        valuePath: 'id'
        labelPath: 'full_name'
    '.preview':
      observe: 'image'
      updateMethod: 'html',
      onGet: (value)->
        $('<img>', 'src': value)

  initialize: (options)->
    _.bindAll @, 'set_preview'
    @model.on 'change:preview', @set_preview
    @klasses = options.klasses
    @mode = options.mode

  getTemplate: ->
    if @mode == 'gallery' then @template_gallery else @template_quote

  set_preview: ->
    @$el.find('.preview').html @model.get('preview')

  onRender: ->
    @stickit()
    @$('.tags').chosen()
    @$('textarea').autosize()

    Backbone.Validation.bind @,
      valid: @valid
      invalid: @invalid

  valid: (view, attr)->
    target = view.$el.find('.preview')
    target.data('tip').deactivate() if target.data('tip')

  invalid: (view, attr, error)->
    target = view.$el.find('.preview')
    target.data('tip').deactivate() if target.data('tip')
    tip = target.opentip(error, {target: target, style: 'alert', tipJoint: 'bottom', showOn: 'creation'})
    target.data('tip', tip)
