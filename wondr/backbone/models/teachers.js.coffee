Wondr.Collections.Teachers = Backbone.Collection.extend

  model: Wondr.Models.Teacher

  url: '/backend/admins'

  comparator: 'full_name'

  filterBy: (attr, values)->
    _.filter @models, (model)->
      _.contains values, model.get(attr)
