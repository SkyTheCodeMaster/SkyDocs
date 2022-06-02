--- Functions for turtles
-- @module[kind=misc] skyrtle

local skyrtle = {}

-- I know that CC:T 1.96.0 supports just `local expect = require("cc.expect")`, but earlier versions does not have this feature, so I'll still be using `local expect = require("cc.expect").expect .
local expect = require("cc.expect").expect

local pos = {
  0,
  0,
  0,
  0, -- Facing, 0 = north, 1 = east, 2 = south, 3 = west.
}

-- Attempt to load last known postion from `.skyrtle`
if fs.exists(".skyrtle") then
  local f = fs.open(".skyrtle","r")
  local c = f.readAll() f.close()
  pos = textutils.unserialize(c)
end

local function fwrite(file,contents)
  local f = fs.open(file,"w")
  f.write(contents)
  f.close()
end

--- Deep copy a table, recurses to nested tables.
-- @tparam table tbl Table to copy. 
-- @treturn table Copied table. 
local function deepCopy(tbl)
  local newTbl = {}
  for k,v in pairs(tbl) do
    if type(v) == "table" then
      newTbl[k] = deepCopy(v)
    else
      newTbl[k] = v
    end
  end
  return newTbl
end

local locate = gps.locate -- Keep copy of gps locate for hijacking

-- Determine if GPS is available
local gps_available = true
local x,y,z = locate()
if not x then -- If GPS isn't available, set XYZ to 000.
  x,y,z = 0,0,0
  gps_available = false
end

if not (gps_available and pos[1] ~= x or pos[2] ~= y or pos[3] ~= z) then -- We're in the same position last time we saved the file.
  pos = {x,y,z,0}
  fwrite(".skyrtle",textutils.serialize(pos))
end

--- A table that converts the output of `skyrtle.getFacing()` into a string.
local dirLookup = {
  [0] = "north",
  "east",
  "south",
  "west",
  --- The number corresponding to north
  north = 0,
  --- The number corresponding to east
  east = 1,
  --- The number corresponding to south
  south = 2,
  --- The number corresponding to west
  west = 3,
  --- Simply the opposite direction for each direction. Used in turtle reversing.
  oppo = {
    [0] = 2,
    3,
    0,
    1,
  },
}

-- if/elseif chain on facing to determine which coordinate to add 1 to when moving
local function addCoord(x,y,z,facing)
  local direction
  if type(facing) == "number" then
    direction = facing
  elseif type(facing) == "string" then
    direction = dirLookup[facing]
  end
  if not direction then error("Direction lookup failed! facing contains an invalid value!") end
  if direction == 0 then -- We're facing north, subtract 1 from Z
    z = z - 1
  elseif direction == 1 then -- We're facing east, add 1 to X
    x = x + 1
  elseif direction == 2 then -- We're facing south, add 1 to Z
    z = z + 1
  elseif direction == 3 then -- We're facing west, subtract 1 from X
    x = x - 1
  end
  return x,y,z
end

--- Get the current facing of the turtle. 
-- @treturn[1] number Current facing of the turtle.
-- @treturn[2] false GPS isn't available.
function skyrtle.calcFacing()
  if not gps_available then return false end
  local start = {locate()}
  turtle.foward()
  local finish = {locate()}
  turtle.back()
  if start[1] + 1 == finish[1] then -- We moved east!
    return 1
  elseif start[1] - 1 == finish[1] then -- We moved west!
    return 3
  elseif start[3] + 1 == finish[3] then -- We moved south!
    return 2
  elseif start[3] - 1 == finish[3] then -- We moved north!
    return 0
  end
end

-- Functions that can replace the turtle api.
local t = deepCopy(turtle) -- Localize the turtle api for replacing it with `skyrtle.replace()`

--- Move the turtle forward N (default 1) blocks.
-- @tparam[opt=1] number blocks The number of blocks to move, defaults to 1.
-- @treturn boolean Whether or not the turtle was able to move the amount of blocks.
function skyrtle.forward(blocks)
  expect(1,blocks,"number","nil")
  blocks = blocks or 1
  local success
  for _=1,blocks do 
    success = t.forward()
    if not success then break end
    pos[1],pos[2],pos[3] = addCoord(pos[1],pos[2],pos[3],pos[4])
  end
  -- Check if we've ended up where we wanted
  if not success and gps_available then
    local mypos = {locate()}
    if mypos[1] == pos[1] and mypos[2] == pos[2] and mypos[3] == pos[3] then
      -- Yep, we're right on target!
      return true 
    else
      return false
    end
  else
    return true 
  end
  return true
end

--- Move the turtle backward N (default 1) blocks.
-- @tparam[opt=1] number blocks The number of blocks to move, defaults to 1.
-- @treturn boolean Whether or not the turtle was able to move the amount of blocks.
function skyrtle.back(blocks)
  expect(1,blocks,"number","nil")
  blocks = blocks or 1
  local success
  for _=1,blocks do
    success = t.back()
    if not success then break end
    pos[1],pos[2],pos[3] = addCoord(pos[1],pos[2],pos[3],dirLookup.oppo[pos[4]])
  end
  -- Check if we've ended up where we wanted
  if not success and gps_available then
    local mypos = {locate()}
    if mypos[1] == pos[1] and mypos[2] == pos[2] and mypos[3] == pos[3] then
      -- Yep, we're right on target!
      fwrite(".skyrtle",textutils.serialize(pos))
      return true 
    else
      return false
    end
  else
    return true 
  end
  return true
end

--- Move the turtle up N times.
-- @tparam[opt=1] number blocks The number of blocks to move, defaults to 1.
-- @treturn boolean Whether or not the turtle was able to move the amount of blocks.
function skyrtle.up(blocks)
  expect(1,blocks,"number","nil")
  blocks = blocks or 1
  local success
  for _=1,blocks do
    success = t.up()
    if not success then break end
    pos[2] = pos[2] + 1
  end
  -- Check if we've ended up where we wanted
  if not success and gps_available then
    local mypos = {locate()}
    if mypos[1] == pos[1] and mypos[2] == pos[2] and mypos[3] == pos[3] then
      -- Yep, we're right on target!
      fwrite(".skyrtle",textutils.serialize(pos))
      return true 
    else
      return false
    end
  else
    return true 
  end
  return true
end

--- Move the turtle down N times.
-- @tparam[opt=1] number blocks The number of blocks to move, defaults to 1.
-- @treturn boolean Whether or not the turtle was able to move the amount of blocks.
function skyrtle.down(blocks)
  expect(1,blocks,"number","nil")
  blocks = blocks or 1
  local success
  for _=1,blocks do
    success = t.down()
    if not success then break end
    pos[2] = pos[2] - 1
  end
  -- Check if we've ended up where we wanted
  if not success and gps_available then
    local mypos = {locate()}
    if mypos[1] == pos[1] and mypos[2] == pos[2] and mypos[3] == pos[3] then
      -- Yep, we're right on target!
      fwrite(".skyrtle",textutils.serialize(pos))
      return true 
    else
      return false
    end
  else
    return true 
  end
  return true
end

--- Turn the turtle left N times.
-- @tparam[opt=1] number turns How many times to turn the turtle, defaults to 1.
-- @treturn boolean Whether or not the turtle was able to turn.
function skyrtle.turnLeft(turns)
  expect(1,turns,"number","nil")
  turns = turns or 1
  for _=1,turns do
    local success = t.turnLeft()
    pos[4] = (pos[4] - 1) % 4
    if not success then fwrite(".skyrtle",textutils.serialize(pos)) return false end
  end
  fwrite(".skyrtle",textutils.serialize(pos))
end

--- Turn the turtle right N times.
-- @tparam[opt=1] number turns How many times to turn the turtle, defaults to 1.
-- @treturn boolean Whether or not the turtle was able to turn.
function skyrtle.turnRight(turns)
  expect(1,turns,"number","nil")
  turns = turns or 1
  for _=1,turns do
    local success = t.turnRight()
    pos[4] = (pos[4] + 1) % 4
    if not success then fwrite(".skyrtle",textutils.serialize(pos)) return false end
  end
  fwrite(".skyrtle",textutils.serialize(pos))
end

--- Get the current facing of the turtle.
-- @treturn number The facing of the turtle represented as a number.
-- @treturn string The facing of the turtle represented as a string.
function skyrtle.getFacing()
  return pos[4], dirLookup[pos[4]]
end

--- Set the current facing of the turtle
-- @tparam number,string dir The facing of the turtle in number or string form, 0 = north, 1 = east, 2 = south, 3 = west.
function skyrtle.setFacing(dir)
  expect(1,dir,"number","string")
  if type(dir) == "string" then dir = dirLookup[dir:lower()] end
  pos[4] = dir
  fwrite(".skyrtle",textutils.serialize(pos))
end

--- Get the current position of the turtle.
-- @treturn number X coordinate of the turtle.
-- @treturn number Y coordinate of the turtle.
-- @treturn number Z coordinate of the turtle. 
function skyrtle.getPosition()
  return pos[1],pos[2],pos[3]
end

--- Set the current position of the turtle. 
-- @tparam number x X coordinate of the turtle.
-- @tparam number y Y coordinate of the turtle. 
-- @tparam number z Z coordinate of the turtle. 
function skyrtle.setPosition(x,y,z)
  expect(1,x,"number")
  expect(1,y,"number")
  expect(1,z,"number")
  pos = {x,y,z,pos[4]}
  fwrite(".skyrtle",textutils.serialize(pos))
end

local function newGPSLocate(timeout,dbug)
  if gps_available then
    return locate(timeout,dbug)
  else
    return skyrtle.getPosition()
  end
end

--- Hijack the turtle API and replace it with Skyrtle functions.
-- @tparam boolean gps Whether or not to replace the GPS api.
-- @treturn boolean Whether or not the changes were applied successfully.
function skyrtle.hijack(doGPS)

  turtle.forward = skyrtle.forward
  turtle.back = skyrtle.back
  turtle.up = skyrtle.up
  turtle.down = skyrtle.down
  turtle.turnLeft = skyrtle.turnLeft
  turtle.turnRight = skyrtle.turnRight

  if doGPS then
    gps.locate = newGPSLocate
  end
  -- This is cursed
  return turtle.forward == skyrtle.forward and turtle.back == skyrtle.back and turtle.up == skyrtle.up and turtle.down == skyrtle.down and turtle.turnLeft == skyrtle.turnLeft and turtle.turnRight == skyrtle.turnRight
end

--- Restore the turtle API and the GPS api
function skyrtle.restore()
  turtle = t
  gps.locate = locate
end

--- Various farming functions
local farm = {}

--- The default check
-- @treturn boolean Whether or not to farm the item
-- @treturn string What to replace it with.
function farm.check()
  local _,data = turtle.inspectDown()
  if data and data.name == "minecraft:wheat" and data.state.age == 7 then
    return true,"minecraft:wheat_seeds"
  end
end

--- A standard farm function, runs the check function and if it passes it will dig down, and place down the seed.
-- @tparam number length How far the turtle should go.
-- @tparam number width How many blocks to the right the turtle should go.
-- @tparam function check Whether or not the turtle should dig, and if it does, what item it should place down as a seed. The default check checks for a wheat growth state of 7. The returns should be a boolean, and a string for the item name. The default check function is @{skyrtle.farm.check}
function farm.farm(length,width,check)
  expect(1,length,"number")
  expect(1,width,"number")
  check = check or farm.check

  local function doCheck()
    local success,item = check()
    if success then
      turtle.digDown()
      turtle.suckDown()
      for i=1,16 do
        local data = turtle.getItemDetail(i)
        if data and data.name == item then
          turtle.select(i)
          turtle.placeDown()
          break
        end
      end
    end
  end
  doCheck() -- Check the one we're currently over.

  for y=1,width do
    for x=1,length do
      if x ~= length then
        turtle.forward()
      end
      doCheck()
    end

    if y ~= width then
      if y%2==0 then -- even, turn left
        turtle.turnLeft()
        turtle.forward()
        doCheck()
        turtle.turnLeft()
      else -- odd, turn right
        turtle.turnRight()
        turtle.forward()
        doCheck()
        turtle.turnRight()
      end
    end
  end
  -- If width is even, we're facing the way we need to go.
  -- If width is odd, we need to turn around.
  if width%2==1 then
    turtle.turnLeft()
    turtle.turnLeft()
  end
  -- If the width is even, then we've already travelled this distance.
  if width%2==1 then
    for _=1,length-1 do
      turtle.forward()
    end
  end
  turtle.turnRight()
  for _=1,width-1 do
    turtle.forward()
  end
  turtle.turnRight()
  turtle.select(1)
  -- We are now at our beginning position :)
end

--- Pathfinding functions
local path = {}

--- Generates a straight line path to the requested coordinates from gps or saved coordinates.
-- This goes Y (Height), then Z and X in straight lines towards the destination.
function path.generate(x,y,z)
  local cx,cy,cz = 0,0,0
  if gps_available then
    cx,cy,cz = gps.locate()
  else
    cx,cy,cz = skyrtle.getPosition()
  end
  local genPath = {}
  while cy ~= y do
    if cy > y then
      table.insert(genPath,"down")
      cy = cy - 1
    else
      table.insert(genPath,"up")
      cy = cy + 1
    end
  end
end

skyrtle.farm = farm
return skyrtle
