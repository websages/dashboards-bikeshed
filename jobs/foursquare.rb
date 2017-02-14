require 'foursquare2'

SCHEDULER.every '5m' do
  begin
    locations = RecentFoursquare.new().recent_checkins
    send_event('foursquare', { items: locations })
  rescue StandardError => e
    puts e
  end
end

class RecentFoursquare
  def recent_checkins
    client = Foursquare2::Client.new(:oauth_token => ENV['FOURSQUARE_OAUTH_TOKEN'], :api_version => '20140830')
    recent_checkins = client.recent_checkins
    locations = []
    for row in recent_checkins[0...10]
      time = Time.at(row['createdAt']).to_i
      locations << {
        label: "#{row['user']['firstName']} #{row['user']['lastName']} @ #{row['venue']['name']} - <em style='color:white;''>#{humanize time} ago</em>",
      }
    end
    return locations
  end

  def humanize secs
    [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        "#{n.to_i} #{name}"
      end
    }.compact.reverse.join(' ')
  end
end
