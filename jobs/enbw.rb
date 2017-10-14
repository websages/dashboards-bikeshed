require 'net/https'
require 'json'
require 'pp'

SCHEDULER.every '5m', first_in: 0 do
  http = Net::HTTP.new('enbw.herokuapp.com', 443)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  request = Net::HTTP::Get.new("/")
  request["Accept"] = "application/json"
  response = http.request(request)
  beers = JSON.parse(response.body)["beers"]
  send_event(
    'enbw',
    beers: beers
  )
end
