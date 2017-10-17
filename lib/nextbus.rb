require 'net/http'
require 'uri'
require 'json'
require 'time'

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

  def format_stop_data(data)
    if data['next'].nil?
      {
        countdown: nil,
        moreinfo: 'Last bus has run for the day.'
      }
    else
      {
        countdown: DateTime.parse('today at ' + data['next']['arrival_time']),
        moreinfo: "Route ##{data['route']['route_id']} / " \
          "#{data['route']['route_long_name']} leaves from #{data['stop_name']}"
      }
    end
  end

  ##
  # Get Times
  def get_times(route, direction, stop_id)
    stop = request("route/#{route}/dir/#{direction}/stop/#{stop_id}")
    format_stop_data(stop)
  end

  private

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
