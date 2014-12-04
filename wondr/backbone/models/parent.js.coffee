Wondr.Models.Parent = Backbone.Model.extend

  url: ->
    '/backend/parents/' + if @isNew() then '' else @get('id')

  paramRoot: 'parent'

  defaults:
    first_name: ''
    last_name: ''
    email: ''

  validation:
    first_name:
      required: true
      msg: 'Please enter first name'

    last_name:
      required: true
      msg: 'Please enter last name'

    email:
      required: true
      msg: 'Please enter e-mail address'
