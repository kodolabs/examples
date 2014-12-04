Wondr.Views.Header = Backbone.Marionette.ItemView.extend

  el: 'header'

  update_state: (current) ->
    @$('#primary li').removeClass('current')
    @$("#primary li.#{current}").addClass('current') if current?

  init: ->
    $('.account').makisu
      selector: 'dd'
      overlap: 0.3
      speed: 0.1

    $(".account").on
      mouseenter: ->
        $(".account").makisu "open"
        return

      mouseleave: ->
        $(".account").makisu "close"
        return

