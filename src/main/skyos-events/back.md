---
module: [kind=skyosevent] back
---
The `back` event is called when the back button is pressed on the action bar.
There are no values with this event.
```lua
while true do
  os.pullEvent("back")
  print("Back button pressed")
end
```