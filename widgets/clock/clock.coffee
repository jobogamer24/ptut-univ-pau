class Dashing.Clock extends Dashing.Widget

  ready: ->
    setInterval(@startTime, 500)

  startTime: =>
    today = new Date()

    h = today.getHours()
    m = today.getMinutes()
    s = today.getSeconds()
    m = @formatTime(m)
    s = @formatTime(s)
    dd = today.getDate()
    mm = today.getMonth() + 1
    yyyy = today.getFullYear()
    if dd < 10
      dd = '0' + dd
    if mm < 10
      mm = '0' + mm
    
    @set('time', h + ":" + m + ":" + s)
    #@set('date', dd + "/" + mm + "/" + yyyy)

    @set('date', today.toLocaleDateString('fr-FR', {
      weekday: 'long', 
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    }))

  formatTime: (i) ->
    if i < 10 then "0" + i else i