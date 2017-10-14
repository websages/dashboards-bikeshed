require 'net/http'
require 'uri'
require 'json'

LYFT_SERVER_TOKEN = ENV["LYFT_SERVER_TOKEN"]
LYFT_LATITUDE     = ENV["LYFT_LATITUDE"]
LYFT_LONGITUDE    = ENV["LYFT_LONGITUDE"]

SCHEDULER.every '5m', :first_in => 0 do |job|

  begin
    uri = URI("https://api.lyft.com/v1/eta?lat=#{LYFT_LATITUDE}&lng=#{LYFT_LONGITUDE}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    request.add_field('Authorization', "Bearer #{LYFT_SERVER_TOKEN}")

    response = http.request(request)
    lyft_response = JSON.parse(response.body)

    pickup_times = []
    lyft_response['eta_estimates'].map do |item|
      estimate = (item['eta_seconds']/60).ceil
      pickup_times << {
        label: item['display_name'],
        value: "#{estimate}m"
      }
    end

    event_name = 'lyft_pickup_time'
    send_event(event_name, { items: pickup_times })
  end

end
