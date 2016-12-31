require 'net/https'
require 'json'
require 'pp'

# Forecast API Key from https://developer.forecast.io
forecast_api_key = ""

# Latitude, Longitude for location
forecast_location_lat = "36.1627"
forecast_location_long = "-86.7816"

# Unit Format
# "us" - U.S. Imperial
# "si" - International System of Units
# "uk" - SI w. windSpeed in mph
forecast_units = "si"

#SCHEDULER.every '5m', :first_in => 0 do |job|
  http = Net::HTTP.new("api.forecast.io", 443)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  puts "api.forecast.io/forecast/#{forecast_api_key}/#{forecast_location_lat},#{forecast_location_long}?units=#{forecast_units}"
  response = http.request(Net::HTTP::Get.new("/forecast/#{forecast_api_key}/#{forecast_location_lat},#{forecast_location_long}?units=#{forecast_units}"))
  pp response
  forecast = JSON.parse(response.body)
  forecast_current_temp = forecast["currently"]["temperature"].round
  forecast_hour_summary = forecast["hourly"]["summary"]
  puts "forecast temperature: #{forecast_current_temp}&deg;, hour: #{forecast_hour_summary}"
  # send_event('forecast', { temperature: "#{forecast_current_temp}&deg;", hour: "#{forecast_hour_summary}"})
#end
