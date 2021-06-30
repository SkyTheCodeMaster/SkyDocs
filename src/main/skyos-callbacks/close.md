---
module: [kind=skyoscallback] SkyOS.close()
---
`SkyOS.close()` is called whenever the window is about to be closed.  
It has no parameters, and expects no returns.
This function is `pcall`ed, so if it errors the entire OS will not crash.