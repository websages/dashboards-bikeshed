require 'net/https'
require 'json'
require 'pp'

# Forecast API Key from https://darksky.net/dev
api_key = ENV['DARKSKY_API_KEY']

# Latitude, Longitude for location
lat = 36.1627
lon = -86.7816

# Unit Format
# "us" - U.S. Imperial
# "si" - International System of Units
# "uk" - SI w. windSpeed in mph
units = 'us'

SCHEDULER.every '5m', first_in: 0 do
  http = Net::HTTP.new('api.darksky.net', 443)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  response = http.request(
    Net::HTTP::Get.new("/forecast/#{api_key}/#{lat},#{lon}?units=#{units}")
  )
  forecast = JSON.parse(response.body)
  current_temp = forecast['currently']['temperature'].round
  hour_summary = forecast['hourly']['summary']
  send_event(
    'forecast',
    temperature: "#{current_temp}&deg;",
    hour: hour_summary
  )
end
