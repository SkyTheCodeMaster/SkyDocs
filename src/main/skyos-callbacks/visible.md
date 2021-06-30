---
module: [kind=skyoscallback] SkyOS.visible()
---
`SkyOS.isVisible(isVisible)` is called whenever the window changes it's visibility state, and therefore active state.  
When a window becomes inactive, it's coroutines will no longer receive user generated events (mouse,keyboard,paste).  
This function is `pcall`ed, if it errors the entire OS will not crash.

## Parameters
1. @{boolean}: Whether or not the window is visible.

It's only parameter is a boolean on whether or not a window is visible. It's true if the window is coming into view, and false if it's going out of view. It expects no returns.