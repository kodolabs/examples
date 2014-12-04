Wondr.Models.Upload = Backbone.Model.extend

  url: '/backend/uploads'

  set_preview: (preview)->
    @set('preview', preview)

  validation:
    student_ids:
      required: true
      msg: 'Please select at least one student'
