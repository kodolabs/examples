Wondr.Models.Student = Backbone.Model.extend

  paramRoot: 'student'

  url: ->
    '/backend/students/' + if @isNew() then '' else @get('id')

  defaults:
    first_name: ''
    last_name: ''
    dob: null
    klass_id: ''

  validation:
    first_name:
      required: true
      msg: 'Please enter first name'

    last_name:
      required: true
      msg: 'Please enter last name'

    dob:
      required: true
      msg: 'Please enter D.O.B'

    klass_id:
      required: true
      msg: 'Please choose a class'

  has_parent: (id)->
    return false if @isNew()
    ids = _.map @get('parents'), (e)->
      e.get('id')

    ids.indexOf(id) >= 0
