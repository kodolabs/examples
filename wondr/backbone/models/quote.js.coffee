Wondr.Models.Quote = Wondr.Models.Post.extend

  defaults:
    type: 'Quote'
    description: ''
    student_ids: []
    topic_ids: []

  validation:
    description:
      required: true
      msg: 'Please enter a quote'
