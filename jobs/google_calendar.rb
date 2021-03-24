require 'icalendar'

ical_url = 'https://ade.univ-pau.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=4554&projectId=1&calType=ical&nbWeeks=4'

uri = URI ical_url

SCHEDULER.every '5m', :first_in => 4 do |job|

  parsed_url = URI.parse(ical_url)
  http = Net::HTTP.new(parsed_url.host, parsed_url.port)
  http.use_ssl = (parsed_url.scheme == "https")
  req = Net::HTTP::Get.new(parsed_url.request_uri)
  result = http.request(req).body.force_encoding('UTF-8')

  calendars = Icalendar::Calendar.parse(result)
  calendar = calendars.first

  events = calendar.events.map do |event|
    {
      start: event.dtstart,
      end: event.dtend,
      summary: event.summary
    }
  end.select { |event| event[:start] > DateTime.now }

  events = events.sort { |a, b| a[:start] <=> b[:start] }

  events = events[0..6]

  send_event('Confluence-Calendar', { data: events })

end
