Wondr.Views.Outcome = Backbone.Marionette.CompositeView.extend

  template: JST['backbone/templates/gallery/outcome']

  tagName: 'li'

  childViewContainer: 'ul'

  events:
    'click p span': 'click'

  initialize: (options)->
    @model.set('nested', options.nested)
    @collection = new Wondr.Collections.Outcomes @model.get('children')

  click: (e)->
    @trigger('collapse')
    @$('ul').slideDown() unless @$('ul').is(':visible')

  collapse: ->
    @$('ul').slideUp()
#
#$("#accordian ul ul").slideUp();
#//slide down the link list below the h3 clicked - only if its closed
#if(!$(this).next().is(":visible"))
#$(this).next().slideDown();
