--- An API to travel to coordinates using Plethora's Kinetic Augment.
-- This REQUIRES Plethora.
-- @module[kind=misc] travel

local modules = peripheral.wrap("back")
 
local function angle(x,y,z)
  return math.deg(math.atan2(-x, z)), math.deg(-math.atan2(y, math.sqrt(x * x + z * z)))
end
 
local function keepHeight(y)
  --while activeHeight do
    local _,height = gps.locate()
    if height and height <= y then
      modules.launch(0,-90,1)
    end
  --end
end
 
--- Move player to set of coordinates within 50 blocks
-- @tparam number x X coordinate to travel to.
-- @tparam number y Y coordinate to travel to.
local function travel(x,z)
  local atDestination = false
  local v = {
    x = x-50,
    w = x+50,
    y = z-50,
    h = z+50,
  }
  while not atDestination do
    local b = vector.new(x,300,z)
    local mx,_,mz = gps.locate()
    local a = vector.new(mx,300,mz)
    --print(a:tostring())
    --[[local theta = math.deg(math.atan(a.z / a.x) - math.atan(b.z / b.x)) -- your angle
    if theta < 0 then theta = theta + 360 end
    if not theta then theta = 0 end
    print(theta)
    modules.launch(theta,0,1)]]
    --print(a)
    --print(b)
    local c = b:sub(a)
    --print(c)
    --print(type(c))
    --print(textutils.serialise(c))
    local yaw = angle(c.x,c.y,c.z)
    --print(yaw)
    modules.launch(yaw,0,4)
    print(mx,mz)
    print(x,z)
    print(mx >= v.x, mx <= v.x + v.w - 1)
    print(mz >= v.y, mz <= v.y + v.h - 1)
    if mx and mz and mx >= v.x and mx <= v.w and mz >= v.y and mz <= v.h then
      atDestination = true
    end
    keepHeight(300)
    sleep()
  end
end
 
return travel