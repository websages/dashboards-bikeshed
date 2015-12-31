require 'fitgem'

class Fitbit

  attr_reader :client, :options, :config

  def initialize(options = {})
    @options = options
    @config  = {
      oauth: {
        consumer_key: ENV['FITBIT_CLIENT_ID'],
        consumer_secret: ENV['FITBIT_CLIENT_SECRET'],
        token: ENV['FITBIT_OAUTH_TOKEN'],
        secret: ENV['FITBIT_OAUTH_TOKEN_SECRET'],
        user_id: ENV['FITBIT_USER_ID']
      }
    }
    @client  = Fitgem::Client.new config[:oauth].merge!(options)
  end

  def device
    {
      version:   'does not matter',
      battery:   'full',
      last_sync: DateTime.iso8601(Date.today.strftime(options[:date_format]))
    }
  end

  def steps
    steps = {
      today: summary["steps"],
      total: total["steps"],
      goal:  percentage(summary["steps"].to_i, goals["steps"].to_i)
    }
    steps.merge meter: meter(steps[:goal]), intensity_class: intensity_class(steps[:goal])
  end

  def calories
    calories = {
      today: summary["caloriesOut"],
      goal:  percentage(summary["caloriesOut"], goals["caloriesOut"])
    }
    calories.merge meter: meter(calories[:goal]), intensity_class: intensity_class(calories[:goal])
  end

  def distance
    distance = {
      today: distance_today,
      goal:  percentage(distance_today.to_f, goals["distance"].to_f).to_i,
      total: total["distance"],
      unit:  distance_unit
    }
    distance.merge meter: meter(distance[:goal]), intensity_class: intensity_class(distance[:goal])
  end

  def active
    active = {
      today: summary["veryActiveMinutes"],
      goal:  percentage(summary["veryActiveMinutes"], goals["activeMinutes"])
    }
    active.merge meter: meter(active[:goal]), intensity_class: intensity_class(active[:goal])
  end

  def leaderboard
    sorted_leaderboard.map do |friend|
      {
        rank:   friend["rank"]["steps"],
        steps:  friend["summary"]["steps"],
        name:   friend["user"]["displayName"],
        avatar: friend["user"]["avatar"],
        style:  leaderboard_style(friend)
      }
    end
  end

  def errors?
    client.devices.is_a?(Hash) && client.devices.has_key?("errors")
  end

  def error
    client.devices["errors"].first["message"]
  end

  private

  def current_device
    client.devices.first
  end

  def today
    client.activities_on_date("today")
  end

  def total
    client.activity_statistics["lifetime"]["total"]
  end

  def distance_unit
    client.user_info["user"]["distanceUnit"] == "en_US" ? "miles" : "km"
  end

  def distance_today
    summary["distances"].select { |item| item["activity"] == "total" }.first["distance"]
  end

  def summary
    today["summary"]
  end

  def goals
    client.goals["goals"]
  end

  def sorted_leaderboard
    client.leaderboard["friends"].sort { |one, other| one["rank"]["steps"] <=> other["rank"]["steps"] }.take 10
  end

  def leaderboard_style(friend)
    me?(friend["user"]["encodedId"]) ? "me" : ""
  end

  def me?(id)
    config[:oauth][:user_id] == id
  end

  def percentage(current, total)
    (current.to_f / (total.to_f / 100)).to_i
  end

  def meter(percentage)
    percentage > 100 ? 100 : percentage
  end

  def intensity_class(percentage)
    intensity = case percentage
    when 0..40
      "none"
    when 41..65
      "light"
    when 66..99
      "moderate"
    when 100
      "high"
    end

    "intensity_#{intensity}"
  end

end

fitbit = Fitbit.new

SCHEDULER.every "10m", first_in: 0 do |job|

  if fitbit.errors?
    send_event "fitbit_leaderboard", { error: fitbit.error }
  else

    listitems = fitbit.leaderboard.map do |row|
      {
        label: row[:name],
        value: row[:steps],
        avatar: row[:avatar]
      }
    end

    send_event "fitbit_list", { items: listitems, image: '/assets/fitbit.png' }
    send_event "fitbit_leaderboard", { people: fitbit.leaderboard }
  end
end
