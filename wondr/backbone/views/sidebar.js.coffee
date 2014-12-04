Wondr.Views.Sidebar = Backbone.Marionette.ItemView.extend

  events:
    'click .js-publish': 'submit'
    'click .tab-links a': 'tab'

  initialize: (options)->
    _.bindAll @, 'on_error', 'on_success', 'on_upload_begin', 'on_upload_end'

    @listenTo Wondr.App.vent, 'upload:begin', @on_upload_begin
    @listenTo Wondr.App.vent, 'upload:end', @on_upload_end

    @klasses = options.klasses

  onShow: ->
    @stickit()

    @$('.tags').chosen()
    @$('.tab-links li:first-child a').trigger('click')

    Backbone.Validation.bind @,
      valid: @valid
      invalid: @invalid



  tab: (e)->
    e.preventDefault()
    element = if e.target then e.target else e.srcElement
    target = $(element).attr('href')
    @$('.tab-content ' + target).show().siblings().hide()
    $(element).parent('li').addClass('active').siblings().removeClass('active')

  on_success: (model)->
    vent = Backbone.Wreqr.radio.channel('global').vent
    vent.trigger 'post:new', model
    vent.trigger 'flash', 'Success'

    Wondr.App.router.navigate '/', trigger: true

  on_error: (model, xhr)->
    errors = Helper.object_to_string xhr.responseJSON.errors
    $(".errors").html "Errors: " + errors

  on_upload_begin: ->
    @$('.js-publish').addClass('loading').html('Uploading')

  on_upload_end: ->
    @$('.js-publish').removeClass('loading').html('Publish')

  valid: (view, attr)->
    target = view.$el.find('#' + attr)
    target.removeClass('error')
    target.opentip('').deactivate()

  invalid: (view, attr, error)->
    target = view.$el.find('#' + attr)
    target.addClass('error')
    target.opentip(error, {target: target, style: 'alert', tipJoint: 'middle left', showOn: 'creation'})
