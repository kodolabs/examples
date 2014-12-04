Wondr.Collections.Posts = Backbone.Collection.extend

  url: '/backend/posts'

  model: (attr, options)->
    if attr.type == 'Gallery'
      new Wondr.Models.Gallery attr, options
    else if attr.type == 'Quote'
      new Wondr.Models.Quote attr, options
