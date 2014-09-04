require 'foursquare2'
require 'action_view'

SCHEDULER.every '5m' do

  locations = RecentFoursquare.new().recent_checkins

  send_event('foursquare', { items: locations })
end

class RecentFoursquare

  include ActionView::Helpers::DateHelper

  def recent_checkins
        client = Foursquare2::Client.new(:oauth_token => ENV['FOURSQUARE_OAUTH_TOKEN'], :api_version => '20140830')
    recent_checkins = client.recent_checkins

    locations = []
    for row in recent_checkins[0...5]

      time = Time.at(row['createdAt'])

      locations << {
        label: "#{row['user']['firstName']} #{row['user']['lastName']} @ #{row['venue']['name']} - <em style='color:white;''>#{time_ago_in_words time} ago</em>",
      }

    end

    return locations

  end

end