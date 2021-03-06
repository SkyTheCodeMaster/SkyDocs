--- A small api to control a Create Mechanical Piston
-- The setup requires (by default) a redstone line to *lower* the piston on the right, and a redstone line to *raise* the piston on the left.
-- The recommended setup for the sequenced gearshifts is: spin 90° on double input speed.
-- @module[kind=create] piston

local expect = require("cc.expect").expect

-- Sides of the redstone lines
local raiseSide = "left"
local lowerSide = "right"
local pulseSpeed = 0.1 -- Create only allows 10 pulses per second.

--- Piston object.
local myPiston = {} --- @type piston
local mt = {["__index"] = myPiston}

--- Raise the piston a set amount of blocks.
-- @tparam[opt=1] number blocks Amount of blocks to raise the piston by.
function myPiston:raise(blocks)
  expect(1,blocks,"number","nil")
  blocks = blocks or 1
  --- Current height of the piston, this should always match the piston in the world.
  local endHeight = math.abs(blocks) + self.curHeight
  if endHeight > myPiston.maxHeight then
    endHeight = myPiston.maxHeight
  end
  local difference = endHeight - myPiston.curHeight
  for _=1,difference do
    redstone.setOutput(raiseSide,true) 
    sleep(pulseSpeed/2)
    redstone.setOutput(raiseSide,false)
    sleep(pulseSpeed/2)
  end
  myPiston.curHeight = endHeight
end

--- Lower the piston a set amount of blocks.
-- @tparam[opt=1] number blocks Amount of blocks to lower the piston by
function myPiston:lower(blocks)
  expect(1,blocks,"number","nil")
  blocks = blocks or 1
  --- Current height of the piston, this should always match the piston in the world.
  local endHeight = self.curHeight - math.abs(blocks)
  if endHeight < 0 then
    endHeight = 0
  end
  for _=myPiston.curHeight,endHeight,-1 do
    redstone.setOutput(lowerSide,true) 
    sleep(pulseSpeed/2)
    redstone.setOutput(lowerSide,false)
    sleep(pulseSpeed/2)
  end
  myPiston.curHeight = endHeight
end

--- Lower the piston to the bottom.
function myPiston:ground()
  for _=myPiston.curHeight,0,-1 do
    redstone.setOutput(lowerSide,true) 
    sleep(pulseSpeed/2)
    redstone.setOutput(lowerSide,false)
    sleep(pulseSpeed/2)
  end
  --- Current height of the piston, this should always match the piston in the world.
  myPiston.curHeight = 0
end

--- Raise the piston to it's maximum extension
function myPiston:max()
  for _=myPiston.curHeight,myPiston.maxHeight do
    redstone.setOutput(raiseSide,true) 
    sleep(pulseSpeed/2)
    redstone.setOutput(raiseSide,false)
    sleep(pulseSpeed/2)
  end
end

--- Create a piston object.
-- @tparam[opt=0] number height Current height of the piston. If not specified will pulse piston 50 times down.
-- @tparam number maxHeight The maximum height of the piston.
local function create(curHeight,maxHeight)
  expect(1,curHeight,"number","nil")
  expect(2,maxHeight,"number")
  if not curHeight then
    for _=1,50 do
      redstone.setOutput(lowerSide,true) 
      sleep(pulseSpeed/2)
      redstone.setOutput(lowerSide,false)
      sleep(pulseSpeed/2)
    end
    curHeight = 1
  end
  local piston = {
    --- Current height of the piston, this should always match the piston in the world.
    curHeight = curHeight,
    --- The maximum height of the piston.
    maxHeight = maxHeight,
  }
  return setmetatable(piston,mt)
end

return {create=create}