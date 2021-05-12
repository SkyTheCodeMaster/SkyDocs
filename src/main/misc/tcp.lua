--- Send packets of data, and make sure they're received. This operates similar to Rednet, in that you send data to a specific ID, which is running a tcp server (refer to tcp installation guide)
-- @module[kind=misc] tcp

--- Channel that messages will be sent on.
local tcp_channel = 30000
local myid = os.getComputerID()

local modem = peripheral.find("modem")
local sha256 = require("sha256")

-- Sha256 digest but pre hexed
local function hash(data)
  local dataHash = sha256.digest(data)
  return dataHash:toHex()
end

local function transmit(id,packet)
  local data = {
    id=id,
    sendid=myid,
    packet=packet,
    hash=hash(packet),
    type="data"
  }
  os.queueEvent("tcp_send",data)
end

--- Yield until a TCP message arrives
-- @treturn number ID of the sender.
-- @return Data of the message.
local function receive()
  local _,sender,data = os.pullEvent("tcp_message")
  return sender,data
end

--- Handshake an ID and return true or false depending on if the connection was successful
-- @tparam number id Computer to connect to.
-- @treturn boolean Whether or not the connection was successful.
local function handshake(id)

end