Wondr.Views.GalleryItems = Backbone.Marionette.CompositeView.extend

  done: 0
  total: 0

  template: JST['backbone/templates/gallery/items']

  childView: Wondr.Views.GalleryItem

  childViewContainer: '#media'

  emptyView: Wondr.Views.PostEmpty

  childViewOptions: ->
    klasses: @klasses
    mode: @mode

  collectionEvents:
    change: 'on_collection_change'

  initialize: (options)->
    _.bindAll @, 'on_add', 'on_progressall', 'on_done', 'on_drop'

    @klasses = options.klasses
    @mode = options.mode

  onShow: ->
    @toggle_instructions()
    @init_fileupload()
    @$('.tags').chosen()

  on_collection_change: ->
    @toggle_instructions()

  on_add: (e, data)->
    return if @max_files()

    file = data.files[0]

    # TODO: check if file is of valid type
    # console.log file.error

    upload = new Wondr.Models.Upload name: file.name, size: file.size, type: file.type
    @collection.add(upload)

    data.context = upload

    Wondr.App.vent.trigger 'sidebar:open'

  on_process: (e, data)->
    preview = data.files[data.index].preview
    if preview?
      data.context.set_preview preview
    else
      data.context.set_preview $('<img>', src: '/assets/preview.png')

  on_done: (e, data)->
    result = data.result
    @done = @done + 1
    @is_done()
    if result.id?
      model = data.context
      model.set(result)

  on_progressall: (e, data)->
#    console.log 'progress', Math.round(data.loaded / data.total * 100), data.total

  on_drop: (e, data)->
    return if @max_files()
    @total = @total + data.files.length
    Wondr.App.vent.trigger 'upload:begin'

  is_done: ->
    Wondr.App.vent.trigger 'upload:end' if @total == @done

  toggle_instructions: ->
    if @collection.length > 0 then @$('#media').removeClass('empty') else @$('#media').addClass('empty')

  max_files: ->
    @mode == 'quote' && @collection.length > 0

  init_fileupload: ->
    @$el.find('#fileupload').fileupload
      url: '/backend/uploads'
      dataType: 'json'
      acceptFileTypes: /(\.|\/)(gif|jpe?g|png|mov|mp4)$/i
      disableImageMetaDataLoad: true
      formData: null
      autoUpload: true
      previewMaxWidth: 383
      previewMaxHeight: 214
      previewCrop: true
      sequentialUploads: true
      # 2 because when we check for collection.length this item already added
      maxNumberOfFiles: if @mode == 'quote' then 2 else 9999
      getNumberOfFiles: =>
        @collection.length

    .on 'fileuploadprocessdone', @on_process
    .on 'fileuploadadd', @on_add
    .on 'fileuploaddone', @on_done
    .on 'fileuploadprogressall', @on_progressall
    .on 'fileuploaddrop', @on_drop
