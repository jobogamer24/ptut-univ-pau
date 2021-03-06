class Dashing.Weather extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    if data.climacon
      # reset classes
      $('i.climacon').attr 'class', "climacon icon-background icon-sun-background #{data.climacon}"
    if data.color
      $(@node).css('background-color', data.color)