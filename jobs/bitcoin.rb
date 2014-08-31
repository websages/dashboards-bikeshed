current_price = 0
current_karma = 0

SCHEDULER.every '5m' do
  last_price = current_price
  current_price = get_bitcoin('USD')

  send_event('bitcoin', { current: current_price, last: last_price })
end

def get_bitcoin(market='USD')
    uri = URI("https://api.bitcoinaverage.com/ticker/global/#{market}/")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)
    bitcoin_response = JSON.parse(response.body)

	bitcoin_response['last']
end