---
module: [kind=skyoscallback] SkyOS.back()
---
`SkyOS.back()` is called when the back button (the `<` on the task bar) is pressed.  
It has no parameters, and expects no returns.
```lua
function SkyOS.back()
  print("Back button pressed")
end
```