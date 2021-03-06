--- Functions for turtles
-- @module[kind=misc] skyrtle

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
  local pos = textutils.unserialize(c)
else pos = {0,0,0,0} end

local function fwrite(file,contents)
  local f = fs.open(file,"w")
  f.write(contents)
  f.close()
end

-- Determine if GPS is available
local gps_available = true
local x,y,z = gps.locate()
if not x then -- If GPS isn't available, set XYZ to 000.
  x,y,z = 0,0,0
  gps_available = false
end

if gps_available and pos[1] ~= x or pos[2] ~= y or pos[3] ~= z then -- We're in the same position last time we saved the file.
  -- uh
else -- We're in a different position! Update the file with our current position.
  pos = {x,y,z,0}
  fwrite(".skyrtle",textutils.serialize(pos))
end

--- A table that converts the output of `skyrtle.getFacing()` into a string.
local dirLookup = {
  [0] = "north",
  "east",
  "south",
  "west",
  north = 0,
  east = 1,
  south = 2,
  west = 3,
  oppo = {
    [0] = 2,
    3,
    0,
    1,
  }
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
local function calcFacing()
  if not gps_available then return false end
  local start = {gps.locate()}
  turtle.foward()
  local finish = {gps.locate()}
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
local t = turtle -- Localize the turtle api for replacing it with `skyrtle.replace()`

--- Move the turtle forward N (default 1) blocks.
-- @tparam[opt=1] number blocks The number of blocks to move, defaults to 1.
-- @treturn boolean Whether or not the turtle was able to move the amount of blocks.
local function forward(blocks)
  expect(1,blocks,"number","nil")
  blocks = blocks or 1
  local success
  for i=1,blocks do 
    success = t.forward()
    if not success then break end
    pos[1],pos[2],pos[3] = addCoord(pos[1],pos[2],pos[3],facing)
  end
  -- Check if we've ended up where we wanted
  if not success and gps_available then
    local mypos = {gps.locate()}
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
local function back(blocks)
  expect(1,blocks,"number","nil")
  blocks = blocks or 1
  local success
  for i=1,blocks do
    success = t.back()
    if not success then break end
    pos[1],pos[2],pos[3] = addCoord(pos[1],pos[2],pos[3],dirLookup.oppo[facing])
  end
  -- Check if we've ended up where we wanted
  if not success and gps_available then
    local mypos = {gps.locate()}
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
local function up(blocks)
  expect(1,blocks,"number","nil")
  blocks = blocks or 1
  local success
  for i=1,blocks do
    success = t.up()
    if not success then break end
    pos[2] = pos[2] + 1
  end
  -- Check if we've ended up where we wanted
  if not success and gps_available then
    local mypos = {gps.locate()}
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
local function down(blocks)
  expect(1,blocks,"number","nil")
  blocks = blocks or 1
  local success
  for i=1,blocks do
    success = t.down()
    if not success then break end
    pos[2] = pos[2] - 1
  end
  -- Check if we've ended up where we wanted
  if not success and gps_available then
    local mypos = {gps.locate()}
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
local function turnLeft(turns)
  expect(1,turns,"number","nil")
  turns = turns or 1
  for i=1,turns do
    local success = t.turnLeft()
    facing = ((facing - 1) % 4)
    if not success then fwrite(".skyrtle",textutils.serialize(pos)) return false end
  end
  fwrite(".skyrtle",textutils.serialize(pos))
end

--- Turn the turtle right N times.
-- @tparam[opt=1] number turns How many times to turn the turtle, defaults to 1.
-- @treturn boolean Whether or not the turtle was able to turn.
local function turnRight(turns)
  expect(1,turns,"number","nil")
  turns = turns or 1
  for i=1,turns do
    local success = t.turnRight()
    facing = ((facing + 1) % 4)
    if not success then fwrite(".skyrtle",textutils.serialize(pos)) return false end
  end
  fwrite(".skyrtle",textutils.serialize(pos))
end

--- Get the current facing of the turtle.
-- @treturn number The facing of the turtle represented as a number.
-- @treturn string The facing of the turtle represented as a string.
local function getFacing()
  return facing, dirLookup[facing]
end

--- Get the current position of the turtle.
-- @treturn number X coordinate of the turtle.
-- @treturn number Y coordinate of the turtle.
-- @treturn number Z coordinate of the turtle. 
local function getPosition()
  return pos[1],pos[2],pos[3]
end

--- Set the current position of the turtle. 
-- @tparam number x X coordinate of the turtle.
-- @tparam number y Y coordinate of the turtle. 
-- @tparam number z Z coordinate of the turtle. 
local function setPosition(x,y,z)
  expect(1,x,"number")
  expect(1,y,"number")
  expect(1,z,"number")
  pos = {x,y,z,facing}
  fwrite(".skyrtle",textutils.serialize(pos))
end

--- Hijack the turtle API and replace it with Skyrtle functions.
-- @treturn boolean Whether or not the changes were applied successfully.
local function hijack()
  turtle.forward = forward
  turtle.back = back
  turtle.up = up
  turtle.down = down
  turtle.turnLeft = turnLeft
  turtle.turnRight = turnRight

  -- This is cursed
  return (turtle.forward == forward and turtle.back == back and turtle.up == up and turtle.down == down and turtle.turnLeft == turnLeft and turtle.turnRight == turnRight)
end

return {
    dirLookup = dirLookup,
      forward = forward,
         back = back,
           up = up,
         down = down,
     turnLeft = turnLeft,
    turnRight = turnRight,
    getFacing = getFacing,
   calcFacing = calcFacing,
  getPosition = getPosition,
  setPosition = setPosition,
       hijack =  hijack,
}