---
module: [kind=skyosevent] long_press
---
This event is called when the user long presses the screen, for longer than `SkyOS.settings.longPressDelay` or 1000 milliseconds by default.
#### **Return Values**
1. @{string}: The event name.
2. @{number}: The mouse button that was clicked.
3. @{number}: The X position of the click.
4. @{number}: The Y position of the click.