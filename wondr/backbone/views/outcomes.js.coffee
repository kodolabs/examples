Wondr.Views.Outcomes = Backbone.Marionette.CollectionView.extend

  childView: Wondr.Views.Outcome

  tagName: 'ul'

  childEvents:
    'collapse': ->
      console.log 'collapse'
      @children.each (c)->
        c.collapse()

