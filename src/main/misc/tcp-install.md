---
module: [kind=misc] TCP Install Guide
---

To install the TCP module, run:  
`wget run https://skydocs.madefor.cc/scripts/installtcp.lua`
This will:
* Download [RedRun](https://gist.github.com/MCJack123/473475f07b980d57dd2bd818026c97e8)
* Move the `startup` file to `startup.bak`
* Download the [TCP Server](https://skydocs.madefor.cc/scriptdata/tcpserver.lua) as the new startup file

The TCP server will still execute `startup.bak`, so your computer will still feel the same.
While the TCP server is active, like redrun, it will convert modem messages into `tcp_message`, which you don't have to worry about, but is available if you want to create your  
own tcp module.  

The tcp_message event is fired when a tcp message is received.

## Return Values
1. @{string}: The event name.
2. @{number}: The ID of the computer this message was received from.
3. @{any}: The message as sent by the sender.
