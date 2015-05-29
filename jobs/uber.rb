require 'net/http'
require 'uri'
require 'json'

UBER_SERVER_TOKEN = ENV["UBER_SERVER_TOKEN"]
UBER_LATITUDE     = ENV["UBER_LATITUDE"]
UBER_LONGITUDE    = ENV["UBER_LONGITUDE"]

SCHEDULER.every '5m', :first_in => 0 do |job|

  begin
    uri = URI("https://api.uber.com/v1/estimates/time?start_latitude=#{UBER_LATITUDE}&start_longitude=#{UBER_LONGITUDE}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    request.add_field("Authorization", "Token #{UBER_SERVER_TOKEN}")

    response = http.request(request)
    uber_response = JSON.parse(response.body)

    pickup_times = []
    uber_response['times'].map do |item|
      estimate = (item['estimate']/60).ceil
      pickup_times << {
        label: item['localized_display_name'],
        value: "#{estimate}m"
      }
    end

    event_name = 'uber_pickup_time'
    send_event(event_name, { items: pickup_times })

  rescue
    puts "\e[33mYou need to add your UBER_SERVER_TOKEN and define a latitude and longitude.\e[0m"
  end

end