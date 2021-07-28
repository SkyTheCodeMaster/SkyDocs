---
module: [kind=skyosevent] long_press
---
This event is called when the user long presses the screen, for longer than `SkyOS.settings.longPressDelay` or 500 milliseconds by default.
#### **Return Values**
1. @{string}: The event name.
2. @{number}: The mouse button that was clicked.
3. @{number}: The X position of the click.
4. @{number}: The Y position of the click.

```lua
while true do
  local _,button,x,y = os.pullEvent("long_press")
  print("Mouse button:",button)
  print(x,y)
end
```