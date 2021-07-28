---
module: [kind=skyoscallback] SkyOS.close()
---
`SkyOS.close()` is called whenever the window is about to be closed.  
It has no parameters, and expects no returns.
```lua
-- Save some data being used to a file
local data = {1,2,3,4}

function SkyOS.close()
  local f,err = fs.open("data.txt","w")
  if not f then error(err) end -- As a note here, this error will get displayed to the user, as `error` is overrided in programs.
  f.write(textutils.serialize(data))
  f.close()
end
```