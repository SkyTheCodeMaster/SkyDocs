---
module: [kind=skyosevent] visible
---
`visible` is queued whenever the window changes it's visibility state, and therefore active state.  
When a window becomes inactive, it's coroutines will no longer receive user generated events (mouse,keyboard,paste).  

## **Return Values**
1. @{boolean}: Whether or not the window is visible.

```lua
while true do
  local _,visible = os.pullEvent("visible")
  print("Is visible:",visible)
end
```