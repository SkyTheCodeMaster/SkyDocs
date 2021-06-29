---
module: [kind=skyos] SkyOS Events/Callbacks
---

# List of events/callbacks
SkyOS has a number of events and callbacks that programs can use. A short list is here:  
* Callback functions  
  1. `SkyOS.close()`  
  2. `SkyOS.visible(isVisible)`  
  3. `SkyOS.back()`  
* Events  
  1. `swipe <direction>`  
  2. `long_press <mouse button> <x> <y>`  
  3. `pan <mouse button> <x> <y>`  
  
## Callback Functions
### **`SkyOS.close()`**
`SkyOS.close()` is called whenever the window is about to be closed.  
It has no parameters, and expects no returns.

### **`SkyOS.visible(isVisible)`**
`SkyOS.isVisible(isVisible)` is called whenever the window changes it's visibility state, and therefore active state.  
When a window becomes inactive, it's coroutines will no longer receive user generated events (mouse,keyboard,paste).  
It's only parameter is a boolean on whether or not a window is visible. It's true if the window is coming into view, and false if it's going out of view. It expects no returns.

### **`SkyOS.back()`**
`SkyOS.back()` is called when the back button (the `<` on the task bar) is pressed.  
It has no parameters, and expects no returns.

## Events
### **swipe**
This event is called when the user swipes on the screen.
#### **Return Values**
1. @{string}: The event name.
2. @{string}: The direction of the swipe. Valid directions are: `"left"`, `"right"`, `"up"`, or `"down"`.

### **long_press**
This event is called when the user long presses the screen, for longer than `SkyOS.settings.longPressDelay` or 1000 milliseconds by default.
#### **Return Values**
1. @{string}: The event name.
2. @{number}: The mouse button that was clicked.
3. @{number}: The X position of the click.
4. @{number}: The Y position of the click.

### **pan**
This event is called when the user clicks and drags on the screen.
#### **Return Values**
1. @{string}: The event name.
2. @{number}: The mouse button that was clicked.
3. @{number}: How many characters X was panned.
4. @{number}: How many characters Y was panned.