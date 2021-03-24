class Dashing.ConfluenceCalendar extends Dashing.Widget

  computeRange: (start, end) ->
    range = moment(start).locale("fr").twix(end)
    retval = range.format({hideDate: true})
    retval

  computeUniq: (dates) ->
    dateact = moment(dates).locale("fr")
    retval = dateact.format('dddd Do')
    retval

  onData: (data) ->
    days = []

    for row in data.data
      row.range = @computeRange(row.start, row.end)
      if @inArray(row, days) == false
        days.push({day: @computeUniq(row.start), events: [] })

    for event in data.data
      for i of days
        if days[i].day == @computeUniq(event.start)
          days[i].events.push(event)
    @set('edt', days)

  inArray: (event, days) ->
    for i of days
      if days[i].day == @computeUniq(event.start)
        return true
    return false    
