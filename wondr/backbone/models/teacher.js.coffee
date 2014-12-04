Wondr.Models.Teacher = Backbone.Model.extend

  paramRoot: 'admin'

  url: ->
    '/backend/admins/' + if @isNew() then '' else @get('id')

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

    email: [
      { required: true, msg: 'Please enter email' }
      { pattern: 'email', msg: 'Please enter valid email' }
    ]

  initialize: ->
    @listenTo @, 'change', @change

  change: (params)->
    @set 'full_name', @get('first_name') + ' ' + @get('last_name')
