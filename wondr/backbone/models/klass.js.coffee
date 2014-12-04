Wondr.Models.Klass = Backbone.AssociatedModel.extend

  url: ->
    '/backend/klasses/' + if @isNew() then '' else @get('id')

  paramRoot: 'klass'

  defaults:
    name: ''
    location: ''
    year: ''
    students: []
    teachers: []

  validation:
    name:
      required: true
      msg: 'Please enter class name'

    location:
      required: true
      msg: 'Please enter location'

    year: [
      { required: true, msg: 'Please enter class year' }
      { pattern: 'digits', msg: 'Please enter only digits' }
    ]

  relations:
    [
      { key: 'students', type: Backbone.Many, collectionType: Wondr.Collections.Students }
    ]
