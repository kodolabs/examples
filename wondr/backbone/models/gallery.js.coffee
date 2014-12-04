Wondr.Models.Gallery = Wondr.Models.Post.extend

  defaults:
    type: 'Gallery'
    name: ''
    description: ''
    topic_ids: []

  validation:
    name:
      required: true
      msg: 'Please enter gallery title'

    description:
      required: true
      msg: 'Please enter gallery description'
