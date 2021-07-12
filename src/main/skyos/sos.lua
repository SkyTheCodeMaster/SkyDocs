--- sos is a library that contains functions pertaining to SkyOS itself
-- @module[kind=skyos] sos

-- TODO: Add individual app icon drawing. Useful for the task view mode.
-- TODO: Add desktop file verification.

local expect = require("cc.expect").expect
local sUtils = require("libraries.sUtils")

local presets = {
  github = {
    user = "SkyTheCodeMaster",
    repo = "SkyOS",
    branch = "master",
    path = "",
  },
}

-- file functions
local function fread(file)
  expect(1,file,"string")
  local f = fs.open(file,"r")
  local contents = f.readAll()
  f.close()
  return contents
end

local function fwrite(file,contents)
  expect(1,file,"string")
  expect(2,contents,"string")
  local f = fs.open(file,"w")
  f.write(contents)
  f.close()
end

local function encfwrite(file,object)
  local obj = textutils.serialize(object)
  fwrite(file,obj)
end

local function encfread(file)
  local contents = fread(file)
  return textutils.unserialize(contents)
end

local function hread(url)
  expect(1,url,"string")
  local h,err = http.get(url)
  if not h then
    return nil,err
  end
  local contents = h.readAll()
  h.close()
  return contents,nil
end

--- Generate a blank desktop file.
-- @treturn table Desktop table according to desktop article.
local function genDesktop()
  return { -- Desktop table
    { -- First screen
      { -- Y1
        {}, -- X1
        {}, -- X2
        {}, -- X3
        {}, -- X4
      },
      {  -- Y2
        {}, -- X1
        {}, -- X2
        {}, -- X3
        {}, -- X4
      },
      { -- Y3
        {}, -- X1
        {}, -- X2
        {}, -- X3
        {}, -- X4
      },
      { -- Y4
        {}, -- X1
        {}, -- X2
        {}, -- X3
        {}, -- X4
      },
    },
  }
end

--- Find next available slot
-- @treturn number Screen position.
-- @treturn number Y position.
-- @treturn number X position.
local function nextAvailable(desktop)
  -- If we iterate over every screen and every y/x position, return #desktop+1, 1, 1
  for i,screen in ipairs(desktop) do
    for y,level in ipairs(screen) do
      for x,spot in ipairs(level) do
        if not spot.name then -- This be a free slot. Lets return it!
          return i,y,x
        end
      end
    end
  end
  return #desktop+1,1,1
end

--- Insert an app into the desktop.
-- @tparam table desktop Desktop to add to.
-- @tparam string name Name of the app.
-- @tparam string image Path to the app icon.
-- @tparam string program Path to the program to open.
--
-- @tparam[2] table desktop Desktop to add to.
-- @tparam[2] {name = string, image = string, program = string}
-- - `name` Name of the app.
-- - `image` Path to the app icon.
-- - `program` Path to the program to open.
local function insertApp(desktop,...)
  local tArgs = {...}
  local options
  if type(tArgs[1]) == "table" then 
    options = tArgs[1]
    expect(2,options["name"],"string")
    expect(3,options["image"],"string")
    expect(4,options["program"],"string")
  elseif type(tArgs[1]) == "string" then
    expect(2,tArgs[2],"string")
    expect(3,tArgs[3],"string")
    expect(4,tArgs[4],"string")
    options = {name = tArgs[1], image = tArgs[2], program = tArgs[3]}
  end
  local s,y,x = nextAvailable()
  if desktop[s] then
    desktop[s][y][x] = options
  else
    desktop[s] = {y={}}
    desktop[s][y][x] = options
  end
end

local function genTimeString()
  local offset
  if SkyOS and SkyOS.settings and SkyOS.settings.timezone then
    offset = SkyOS.settings.timezone
  else
    offset = 0
  end
  local epoch = math.floor(os.epoch("utc") / 1000) + 3600 * offset
  local t = os.date("!*t",epoch)
  local time = {
    sec = t.sec,
    min = t.min,
    hour = t.hour,
    day = t.day,
    month = t.month,
    year = t.year,
  }
  for k,v in pairs(time) do
    local str = tostring(v)
    if str:len() == 1 then
      str = "0" .. str
    end
    time[k] = str
  end
  local filepath = "screenshots/" .. time.hour .. time.min .. time.sec .. "-" .. time.day .. time.month .. time.year .. ".skimg"
  return filepath
end

--- Screenshot the screen, and save it to `/screenshots/hhmmss-ddmmyyyy.skimg`
local function screenshot()
  if not term.current().getLine then
    -- We don't have screenshotting available, yikes.
    return
  end
  local x,y = term.getSize()
  local data = {}
  for i=1,y do
    local text,fg,bg = term.current().getLine(i)
    data[i] = {text,fg,bg,i}
  end
  local creator = os.getComputerLabel() or "SkyOS"
  local attributes = {
    x=x,
    y=y,
    creator=creator,
    locked=false,
    type=1,
  }
  local skimg = {attributes=attributes,data=data}
  local filepath = genTimeString()
  encfwrite(filepath,skimg)
end


return {
  screenshot = screenshot,
  --- Functions to interact with the desktop file.
  desktop = {
    nextAvailable = nextAvailable,
    insertApp = insertApp,
  },
}