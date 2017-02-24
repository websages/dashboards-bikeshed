require 'net/http'
require 'uri'
require 'json'
require 'time'

NEXTBUS_API_KEY = ENV['NEXTBUS_API_KEY']
NEXTBUS_LATLON = ENV['NEXTBUS_LATLON']

SCHEDULER.every '1m', first_in: 0 do
  api = NextBus.new(api_key: NEXTBUS_API_KEY)

  search_results = api.nearby_stops(NEXTBUS_LATLON)

  stops = []
  search_results.each do |search|
    stops << search['stop_id']
  end

  stops.each do |stop|
    send_event("nextbus_#{stop}", api.stop_data(stop))
  end
end

##
# NextBus
class NextBus
  attr_reader :options, :api_key

  def initialize(options = {})
    @options = options
    @api_key = options[:api_key]
  end

  def nearby_stops(lat_lon)
    # Get list of stops in the area
    request("findstop/#{lat_lon}")
  end

  def stop_data(stop)
    data = request("stop/#{stop}")
    if data['next'].nil?
      {
        title: data['stop_name'], text: 'No next bus. :('
      }
    else
      next_stop = Time.parse("#{data['next']['arrival_time_str']} #{Time.now.dst? ? 'CDT' : 'CST'}")
      {
        title: data['stop_name'], text: humanize(next_stop.to_i),
        moreinfo: "Route ##{data['next']['route_id']} / #{data['next']['route_long_name']} leaves at #{data['next']['arrival_time_str']}"
      }
    end
  end

  private

  def humanize secs
    [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        "#{n.to_i} #{name}"
      end
    }.compact.reverse.join(' ')
  end

  def request(endpoint)
    uri = URI("https://nextbus.jt2k.com/api/#{endpoint}?key=#{api_key}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)
    JSON.parse(response.body)
  end
end
