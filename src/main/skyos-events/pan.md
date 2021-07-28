---
module: [kind=skyosevent] pan
---
This event is queued while the user clicks and drags on the screen.
## **Return Values**
1. @{string}: The event name.
2. @{string}: The direction being panned, `left`, `right`, `up`, `down`.

```lua
while true do
  local _,dir = os.pullEvent("pan")
  print("Pan direction:",dir)
end
```