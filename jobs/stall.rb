SCHEDULER.every '20s' do

  output = `/usr/local/bin/lasttripped`

  status_images = {
    full:  '/stall/shittersfull.jpg',
    empty: '/stall/shittersclear.jpg'
  }

  if output =~ /open/
    image_path = status_images[:empty]
  else
    image_path = status_images[:full]
  end

  send_event('stall_status', { image: image_path })
end
