Wondr.Views.QuoteSidebar = Wondr.Views.Sidebar.extend

  template: JST['backbone/templates/quote/sidebar']

  bindings:
    '#description': 'description'
    '#student_ids':
      observe: 'student_ids'
      selectOptions:
        collection: ->
          res = opt_labels: []
          _.each @klasses.models, (klass)->
            res.opt_labels.push klass.get('name')
            res[klass.get('name')] = []
            _.each klass.get('students').models, (student)->
              res[klass.get('name')].push id: student.get('id'), full_name: student.get('full_name')
          res

        valuePath: 'id'
        labelPath: 'full_name'

  submit: (e)->
    e.preventDefault()

    @model.set 'uploads_data', @collection.prepare_for_submit()

    @model.save {},
      success: @on_success
      error: @on_error

