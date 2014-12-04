Wondr.Collections.Uploads = Backbone.Collection.extend

  model: Wondr.Models.Upload

  get_ids: ->
    _.map @models, (e)->
      e.get('id')

  prepare_for_submit: ->
    _.map @models, (model)->
      attributes = {}
      _.each ['id', 'description', 'student_ids'], (key)->
        attributes[key] = model.get(key)
      attributes

