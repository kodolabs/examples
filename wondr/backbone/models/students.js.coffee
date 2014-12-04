Wondr.Collections.Students = Backbone.Collection.extend

  model: Wondr.Models.Student

  url: '/backend/students'

  comparator: 'full_name'
