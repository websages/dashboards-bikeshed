require 'net/http'
require 'uri'
require 'json'

NEXTBUS_API_KEY = ENV['NEXTBUS_API_KEY']
NEXTBUS_STOP_LIST = ENV['NEXTBUS_STOP_LIST'] || ''

SCHEDULER.every '1m', first_in: 0 do
  NEXTBUS_STOP_LIST.split(',').each do |stop|
    uri = URI("http://nextbus.jt2k.com/api/stop/#{stop}?key=#{NEXTBUS_API_KEY}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = false
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)
    data = JSON.parse(response.body)
    next if data.nil?

    puts data.inspect

    if data['next'].nil?
      send_event(
        "nextbus_#{stop}",
        title: data['stop_name'],
        text: 'No next bus. :('
      )
    else
      nextbus = data['next']
      send_event(
        "nextbus_#{stop}",
        title: data['stop_name'],
        text: "#{nextbus['arrival_time_str']}",
        moreinfo: "Route ##{nextbus['route_id']} / #{nextbus['route_long_name']}"
      )
    end
  end
end
