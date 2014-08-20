require 'net/http'
require 'uri'
require 'json'

# ---------------------------------------------vvv Your API key (contact BCycle and sign TOS)
BCYCLE_API_KEY    = ENV["BCYCLE_API_KEY"]    || "YOUR-API-KEY-HERE"
BCYCLE_PROGRAM_ID = ENV["BCYCLE_PROGRAM_ID"] || 0
# ---------------------------------------------^^^ Station ID (e.g. 64 - Nashville)

SCHEDULER.every '5m', :first_in => 0 do |job|

  # Define keys if not defined
  BCYCLE_API_KEY = '' unless defined?(BCYCLE_API_KEY)
  BCYCLE_PROGRAM_ID = 0 unless defined?(BCYCLE_PROGRAM_ID)

  begin
    uri = URI("https://publicapi.bcycle.com/api/1.0/ListProgramKiosks/#{BCYCLE_PROGRAM_ID}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    request.add_field("ApiKey", BCYCLE_API_KEY)

    response = http.request(request)
    stations = JSON.parse(response.body)

    stations = stations.map do |row|
      row = {
        :id => row['Id'],
        :name => row['Name'],
        :status => row['Status'],
        :hours => row['HoursOfOperation'],
        :bikes_available => row['BikesAvailable'],
        :docks_available => row['DocksAvailable'],
        :total_docks => row['TotalDocks']
      }
    end

    stations.each { |station|
      event_name = 'bcycle_'+station[:id].to_s
      send_event(event_name, station)
    }

  rescue
    puts response.body
    puts "\e[33mYou need to add your BCYCLE_API_KEY and define a BCYCLE_PROGRAM_ID.\e[0m"
  end

end