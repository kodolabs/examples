Wondr.Views.TimelineItem = Backbone.Marionette.ItemView.extend

  tagName: 'li'

  template: JST['backbone/templates/timeline/item']

  templateHelpers:
    cover: ->
      image = @uploads[0].image if @uploads.length > 0
      image = image ? '/assets/quote.jpeg'
