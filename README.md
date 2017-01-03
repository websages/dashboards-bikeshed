dashing-bnagh
-------------

Development
===========

```
bundle install
cp .app-env-dist .app-env
script/server
```

Then access over http://localhost:3030

Raspberry Pi
=============

As pi on your raspberry pi:

```
(cd ~; [ -d dashing ] && rm -fr dashing ; git clone https://github.com/websages/dashboards-bnagh dashing; sudo dashing/INSTALL)
```

will set up the device to boot into dashing.

You will need to enable boot-to-graphical mode with raspi-config as well.

Any secrets should be exported to the environment in ```/home/pi/.app-env```.

