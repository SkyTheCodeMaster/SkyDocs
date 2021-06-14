--- This is a communications library for SkyOS to facilitate communication with in world computers. This requires PG231's ECC library to be placed at "/libraries/ecc.lua"
-- @module[kind=wip] comms 

if not fs.exists("/libraries/ecc.lua") then
  error("Please place ECC library @ /libraries/ecc.lua.\npastebin get ZGJGBJdg /libraries/ecc.lua")
end

local ecc = require("libraries.ecc")
local modem = peripheral.find("modem")

-- Store keys for computers.
-- [id] = {key = key, private = private, public = public}
-- Key is the result of `ecc.exchange(private,public)`
-- Private is the session's private key.
-- Public is the received public key.
local keys = {

}

--- Generate the exchange key, private key, and whatnot.
-- @tparam number id ID of target computer.
-- @param publicKey The received public key.
-- @usage ```lua
-- local _,_,_,_,key = os.pullEvent("modem_message")
-- comms.generate(1,key)
local function generate(id,publicKey)
  local private,public = ecc.keypair()
  
end