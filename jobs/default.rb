SCHEDULER.every '5m', :first_in => 0 do |job|

  # dashboard_list = Dir["dashboards/*.erb"]
  dashboard_list = Dir["dashboards/*.erb"]

  puts dashboard_list.inspect

  dashboards = []
  for dashboard in dashboard_list
    next if dashboard === 'dashboards/layout.erb'
    puts dashboard
    dashboard = dashboard.match(/^dashboards\/(.*)\.erb$/)[1]
    dashboards << {
      label: dashboard,
      value: "<a href='#{dashboard}'>Go</a>"
    }
  end

  send_event('dashboards', { items: dashboards })

end
