require 'foursquare2'

SCHEDULER.every '10s' do

  client = Foursquare2::Client.new(:oauth_token => ENV['FOURSQUARE_OAUTH_TOKEN'], :api_version => '20140830')
  recent_checkins = client.recent_checkins

  locations = []
  for row in recent_checkins[0...5]

    time = Time.at(row['createdAt'])

    locations << {
      label: "#{row['user']['firstName']} #{row['user']['lastName']} @ #{row['venue']['name']}",
      value: "#{time}"
    }

  end

  send_event('foursquare', { items: locations })
end