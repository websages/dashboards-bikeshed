fitbit = Fitbit.new

SCHEDULER.every "15m", first_in: 0 do |job|
  puts fitbit.leaderboard.inspect
  if fitbit.errors?
    send_event "fitbit_leaderboard", { error: fitbit.error }
  else
    send_event "fitbit_leaderboard", { people: fitbit.leaderboard }
  end
end
