---
module: [kind=skyosevent] pan_up
---
This event is called when the `pan` event ends, and the mouse button is lifted.
## **Return Values**
1. @{string}: The event name.
2. @{number}: The mouse button that was clicked.
3. @{number}: How many characters X was panned.
4. @{number}: How many characters Y was panned.

```lua
while true do
  local _,button,x,y = os.pullEvent("pan_up")
  print("Mouse button:",button)
  print("X Panned:",x,"Y Panned:",y)
end
```