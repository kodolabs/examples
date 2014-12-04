Wondr.Views.Timeline = Backbone.Marionette.CollectionView.extend

  id: 'timeline'

  tagName: 'ul'

  className: 'galleries'

  childView: Wondr.Views.TimelineItem

  emptyView: Wondr.Views.TimelineEmpty
