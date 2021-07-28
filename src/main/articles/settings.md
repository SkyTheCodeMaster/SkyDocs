---
module: [kind=articles] SkyOS Settings
---
The SkyOS settings file (Found at `settings/general.cfg`) contains a number of options to change how SkyOS works. All of these will be configurable inside SkyOS, mostly through the `Settings` program.  
The current list of settings (subject to change) and their descriptions are as follows:  
  
* `timezone = 0`: This is a number representing the timezone offset from UTC. In default SkyOS this only has an effect if `useRealtime` is enabled.  
* `useRealtime = true`: This affects the default clock in SkyOS to either use real time, or ingame time.
* `desktopImg = "graphics/background/default.skimg"`: This changes the background (or "wallpaper") of the desktop, to whatever `skimg` is provided. This must be a 26x18 `.skimg` file.
* `internet = true`: This enables/disables most of SkyOS' internet-facing features, such as the integrity check.
* `location = true`: This enables/disables the GPS system, if it's off `gps.locate` will only return nil, and the location icon in the top bar red. If it's activated every time gps is used the location icon will flash white from it's default grey.
* `longPressDelay = 500`: This is how long in milliseconds a press (and hold) should be before a `long_press` event gets queued once the `mouse_up` event is received.