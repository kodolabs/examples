Wondr.Models.Post = Backbone.Model.extend

  paramRoot: 'post'

  url: ->
    '/backend/posts/' + if @isNew() then '' else @get('id')

  isGallery: ->
    @get('type') == 'Gallery'
