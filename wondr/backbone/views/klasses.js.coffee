Wondr.Views.Klasses = Backbone.Marionette.CollectionView.extend

  childView: Wondr.Views.Klass

  initialize: (options)->
    @parents = options.parents

  childViewOptions: ->
    parents: @parents
