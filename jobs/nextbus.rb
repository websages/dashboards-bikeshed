require 'net/http'
require 'uri'
require 'json'

NEXTBUS_API_KEY = ENV['NEXTBUS_API_KEY']
NEXTBUS_LATLON = ENV['NEXTBUS_LATLON']

SCHEDULER.every '1m', first_in: 0 do

  api = NextBus.new(api_key: NEXTBUS_API_KEY)

  search_results = api.nearby_stops(NEXTBUS_LATLON)
  puts search_results

  stops = []
  search_results.each do |search|
    stops << search['stop_id']
  end

  stops.each do |stop|
    send_event("nextbus_#{stop}", api.stop_data(stop))
  end
end

class NextBus

  attr_reader :options, :api_key

  def initialize(options = {})
    @options = options
    @api_key = options[:api_key]
  end

  def nearby_stops(lat_lon)
    # Get list of stops in the area
    uri = URI("http://nextbus.jt2k.com/api/findstop/#{lat_lon}?key=#{api_key}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = false
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)
    JSON.parse(response.body)
  end

  def stop_data(stop)
    uri = URI("http://nextbus.jt2k.com/api/stop/#{stop}?key=#{api_key}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = false
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)
    data = JSON.parse(response.body)

    if data['next'].nil?
      {
        title: data['stop_name'],
        text: 'No next bus. :('
      }
    else
      {
        title: data['stop_name'],
        text: data['next']['arrival_time_str'],
        moreinfo: "Route ##{data['next']['route_id']} / #{data['next']['route_long_name']}"
      }
    end
  end

end

