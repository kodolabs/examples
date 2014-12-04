Wondr.Collections.Parents = Backbone.Collection.extend

  model: Wondr.Models.Parent

  url: '/backend/parents'

  comparator: 'full_name'

  filterBy: (attr, values)->
    _.filter @models, (model)->
      _.contains values, model.get(attr)
