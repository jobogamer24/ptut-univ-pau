require 'net/http'
require 'icalendar'
require 'icalendar/recurrence'
require 'time'
require 'tzinfo'
require 'pp'

class Event2
  attr_reader :summary
  attr_reader :dtend
  attr_reader :dtstart
  attr_reader :attendee

  def initialize(summary, dtstart, dtend, attendee)
    @summary  = summary
    @dtend    = dtend
    @dtstart  = dtstart
    @attendee = attendee
  end
end

def get_calendar()
  url = URI.parse("https://ade.univ-pau.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=4554&projectId=1&calType=ical&nbWeeks=4")
  request  = Net::HTTP::Get.new(url.to_s)
  response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') {|http|
	http.request(request)
  }
  response.body.force_encoding('UTF-8')
end

def event_hash(event, tz)
  def get_time(t, tz)
    if t.to_s.include?('UTC')
      t.utc.strftime('%Y-%m-%dT%H:%M:%S%z')
    else
      t1 = use_time_zone(t, tz)
      t1.utc.strftime('%Y-%m-%dT%H:%M:%S%z')
    end
  end

  interval = event.dtend - event.dtstart
  delta = interval < (60*60*24) ? 0 : Rational(1, 60*60*24)
  attendees = event.attendee.collect { |att| att.ical_params['cn'] }.join(', ')
  {
      :summary   => event.summary,
      :start     => get_time(event.dtstart + delta, tz),
      :end       => get_time(event.dtend - delta, tz),
      :attendees => attendees,
      :show      => event.summary.include?(attendees) ? 'hidden' : ''
  }
end

def with_time_zone(tz_name)
  prev_tz = ENV['TZ']
  ENV['TZ'] = tz_name
  yield
ensure
  ENV['TZ'] = prev_tz
end

def use_time_zone(t, tz)
  with_time_zone(tz) {Time.new(t.year, t.month, t.mday, t.hour, t.min, t.sec)}

end

def update_calendar()
    ics       = get_calendar()
    calendars = Icalendar::Calendar.parse(ics)
	puts ics

    calendars.each do |calendar|

      tz = calendar.x_wr_timezone[0].to_s

      cal_data = calendar.events.
          collect { |event|
            event.rrule ?
                event.occurrences_between(Date.today - 1, Date.today + 90).collect { |occurrence|
                  Event2.new(event.summary, occurrence.start_time, occurrence.end_time, event.attendee)
                } :
                [Event2.new(event.summary, event.dtstart, event.dtend, event.attendee)]
          }.
          flatten.
          select { |event| event.is_a?(Date) ? event.dtend > Date.today - 1 : event.dtend > Time.now }.
          collect { |event| event_hash(event, tz) }.
          sort_by { |event| event[:start] }.
          take(7)

      send_event("Confluence-Calendar", {:data => cal_data})
	  puts cal_data

    end
end

SCHEDULER.every '5m', :first_in => 0 do |id|
  update_calendar()
end
