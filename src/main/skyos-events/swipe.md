---
module: [kind=skyosevent] swipe
---
This event is called when the user swipes on the screen.
## **Return Values**
1. @{string}: The event name.
2. @{string}: The direction of the swipe. Valid directions are: `"left"`, `"right"`, `"up"`, or `"down"`.

```lua
while true do
  local _,dir = os.pullEvent("swipe")
  print("Swipe direction:",dir)
end
```