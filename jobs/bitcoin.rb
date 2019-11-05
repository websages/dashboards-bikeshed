# Defaults
btc_current_price = 0
eth_current_price = 0

SCHEDULER.every '10m', first_in: 0 do
  # Bitcoin
  btc_last_price = btc_current_price
  btc_current_price = get_coinbase_data('BTC')

  # Etherium
  eth_last_price = eth_current_price
  eth_current_price = get_coinbase_data('ETH')

  # Ripple
  xrp_last_price = eth_current_price
  xrp_current_price = get_coinbase_data('XRP')

  send_event(
    'bitcoin',
    current: btc_current_price,
    last: btc_last_price,
    prefix: '$'
  )

  send_event(
    'etherium',
    current: eth_current_price,
    last: eth_last_price,
    prefix: '$'
  )

  send_event(
    'ripple',
    current: xrp_current_price,
    last: xrp_last_price,
    prefix: '$'
  )
end

##
# Get Coinbase Prices
def get_coinbase_data(coin)
  uri = URI("https://api.coinbase.com/v2/exchange-rates?currency=#{coin}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri)

  response = http.request(request)
  bitcoin_response = JSON.parse(response.body)

  bitcoin_response['data']['rates']['USD']
end
