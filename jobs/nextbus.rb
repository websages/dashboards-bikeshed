require './lib/nextbus'

NEXTBUS_API_KEY = ENV['NEXTBUS_API_KEY']

SCHEDULER.every '1m', first_in: 0 do
  api = NextBus.new(api_key: NEXTBUS_API_KEY)

  routes = [
    {
      route: 4,
      direction: 0,
      stop_id: 'MCC4_18'
    },
    {
      route: 28,
      direction: 1,
      stop_id: 'MCC4_22'
    },
    {
      route: 50,
      direction: 0,
      stop_id: 'MCC5_1'
    },
    {
      route: 10,
      direction: 0,
      stop_id: 'MCC5_3'
    },
    {
      route: 19,
      direction: 1,
      stop_id: 'MCC5_4'
    },
    {
      route: 3,
      direction: 0,
      stop_id: 'MCC5_5'
    }
  ]

  routes.each do |route|
    time = api.get_times(route[:route], route[:direction], route[:stop_id])
    send_event("nextbus_#{route[:stop_id]}", time)
  end
end
