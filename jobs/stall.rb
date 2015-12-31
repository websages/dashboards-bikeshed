SCHEDULER.every '20s' do
  if File.exist? '/usr/local/bin/lasttripped'
    output = `/usr/local/bin/lasttripped`

    status_images = {
      full:  'assets/stall/shittersfull.jpg',
      empty: 'assets/stall/shittersclear.jpg'
    }

    if output =~ /open/
      image_path = status_images[:empty]
    else
      image_path = status_images[:full]
    end

    send_event('stall_status', { image: image_path })
  else
    puts "Could not find stall binary."
    send_event('stall_status', { image: 'assets/stall/shittersclear.jpg' })
  end
end
