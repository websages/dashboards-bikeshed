require 'net/http'
require 'uri'
require 'json'

# Configure the program city
BCYCLE_CITY = (ENV['BCYCLE_CITY'] || 'nashville').downcase

##
# Get BCycle Data
def get_bcycle_data(city, type)
  uri = URI("https://gbfs.bcycle.com/bcycle_#{city}/#{type}.json")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  response = http.request(Net::HTTP::Get.new(uri.request_uri))
  JSON.parse(response.body)
rescue StandardError => e
  puts response.body
  puts e.inspect
  puts "\e[33mUnable to retrieve BCycle data.\e[0m"
end

SCHEDULER.every '5m', { first_in: 0 } do |job|
  # Stations
  stations = get_bcycle_data(BCYCLE_CITY, 'station_information')
  raise stations['error'] if stations.key?('error')

  # Statuses
  station_statuses = get_bcycle_data(BCYCLE_CITY, 'station_status')
  raise station_statuses['error'] if station_statuses.key?('error')

  # Build Status Dictionary
  statuses = {}
  station_statuses['data']['stations'].each do |status|
    statuses[status['station_id']] = status
  end

  # Send Data
  stations['data']['stations'].each do |station|
    data = {
      id: station['station_id'],
      name: station['name'],
      bikes_available: statuses[station['station_id']]['num_bikes_available'],
      docks_available: statuses[station['station_id']]['num_docks_available'],
      status: statuses[station['station_id']]['is_renting'] == 1 ? 'Active' : 'Unavailable'
    }
    send_event(station['station_id'], data)
  end
end
