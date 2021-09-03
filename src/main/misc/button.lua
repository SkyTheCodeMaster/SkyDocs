--- A simple button api with the option of drawing an image on the button.
-- @usage Create a simple button
--   local button = require("libs.button")
--   local id = button.new(1,1,5,5,function()
--     print("Hi!")
--   end)
--
--  while true do
--    button.exec({os.pullEvent()})
--  end
--

-- @module[kind=misc] button

local expect = require("cc.expect").expect
--- idLength is how long the specific IDs are, if you have lots of buttons, this should go higher.
local idLength = 6 -- This is the length of the unique identifiers for buttons.
--- strictImage forces the image to be the same height and width as the button
local strictImage = false -- This confirms that the image is the same height as the button.
local buttons = {}

local function genRandID(length)
  local str = ""
  for _=1,length do
    local num = math.random(48,109)
    if num >= 58 then num = num + 7 end
    if num >= 91 then num = num + 6 end
    str = str .. string.char(num)
  end
  return str
end

--[[- Create a button, and add it to the internal table of buttons.
  @tparam number x X coordinate of the button.
  @tparam number y Y coordinate of the button.
  @tparam number width Width of the button.
  @tparam number height Height of the button.
  @tparam function function The function to run when the button is clicked.
  @tparam[opt] table image Table of blit lines to draw on the button.
  @tparam[opt] boolean enabled Whether or not the button is active. Defaults to true.
  @treturn string id id of the button
  @usage Create a simple button.
    local button = require("libs.button")
    local id = button.new(1,1,5,5,function()
      print("Hi!")
    end)

  @usage Create a button with an image
    local button = require("libs.button")
    local image = {
      {
        "+-----+",
        "0000000",
        "fffffff",
      },
      {
        "|Image|",
        "0000000",
        "fffffff",
      }
      {
        "+-----+",
        "0000000",
        "fffffff",
      },
    }
    local id = button.new(1,1,7,3,function() print("Clicked!") end,image) -- Note the `image` parameter passed here.
]]
local function new(nX,nY,nW,nH,fFunc,tDraw,enabled) -- tDraw is a table of blit lines. This function will check they're the same length.
  expect(1,nX,"number")
  expect(1,nY,"number")
  expect(1,nW,"number")
  expect(1,nH,"number")
  expect(1,fFunc,"function")
  expect(1,tDraw,"table","nil")
  expect(1,enabled,"boolean","nil")
  enabled = enabled == nil and true or false -- retain old behaviour

  local mX,mY = term.getCursorPos()

  if tDraw then -- If a blit table is passed, loop through it and make sure it's a valid (ish) table, and make sure it's the same height & width as the button.
    if strictImage then
      if #tDraw ~= nH then
        error("Image must be same height as button",2)
      end
    end
    for i=1,#tDraw do
      if #tDraw[i][1] ~= #tDraw[i][2] or #tDraw[i][1] ~= #tDraw[i][3] then
        error("tDraw line" .. tostring(i) .. "is not equal to other lines",2)
      end
      if strictImage then
        if #tDraw[i][1] ~= nW then
          error("Image must be same width as button",2)
        end
      end
    end
  end

  local id = genRandID(idLength)

  buttons[id] = { -- Store the information about the button in the buttons table.
    x = nX,
    y = nY,
    w = nW,
    h = nH,
    fFunc = fFunc,
    tDraw = tDraw,
    enabled = enabled,
  }

  if tDraw then -- If a blit table is passed, loop through it and draw it.
    for i=1,#tDraw do
      local frame = tDraw[i]
      term.blit(frame[1],frame[2],frame[3])
    end
  term.setCursorPos(mX,mY)
  end

  return id
end

--- Remove a button from being clicked.
-- @tparam string id button id to remove.
local function delete(id) -- This doesn't remove the image if any!
  expect(1,id,"string","nil")
  if buttons[id] then
    buttons[id] = nil
  end
end

--- Enable or disable a button.
-- @tparam string id Button to enable or disable.
-- @tparam boolean enable Whether the button is enabled or not.
local function enable(id,enable)
  expect(1,id,"string")
  expect(2,enable,"boolean")
  if not buttons[id] then error("Button " .. id .. " does not exist.",2) end
  buttons[id].enabled = enable
end

--- Takes an event in a table, checks if it's a `mouse_click` or `mouse_drag`, and sees if it's within a button, if so, execute it's function.
-- @tparam table event Event table to check for `mouse_click` or `mouse_drag`.
-- @tparam[opt] boolean drag Enable button trigger on a `mouse_drag` event. Defaults to false.
-- @tparam[opt] boolean monitor Enable button trigger on a `monitor_touch` event. Defaults to false.
local function exec(tEvent,bDrag,bMonitor)
  expect(1,tEvent,"table")
  expect(2,bDrag,"boolean","nil")
  expect(3,bMonitor,"boolean","nil")
  bDrag = bDrag or false
  bMonitor = bMonitor or false
  if tEvent[1] == "mouse_click" or bDrag and tEvent[1] == "mouse_drag" or bMonitor and tEvent[2] == "monitor_touch" then
    local x,y = tEvent[3],tEvent[4]
    for _,v in pairs(buttons) do
      if v.enabled and x >= v.x and x <= v.x + v.w - 1 and y >= v.y and y <= v.y + v.h - 1 then
        pcall(v.fFunc,x-v.x+1,y-v.y+1)
      end
    end
  end
end

--- Draw a button again, drawing it's `tDraw`, or nothing if there is no image.
-- @tparam string id Button ID to draw image of.
local function drawButton(id)
  expect(1,id,"string")
  if buttons[id] and buttons[id].tDraw then
    local image = buttons[id].tDraw
    local x,y,w,h = buttons[id].x,buttons[id].y,buttons[id].w,buttons[id].h
    if strictImage then
      if #image ~= h then
        error("image must be same height as button",2)
      end
    end
    for i=1,#image do
      if #image[i][1] ~= #image[i][2] or #image[i][1] ~= #image[i][3] then
        error("image line" .. tostring(i) .. "is not equal to other lines",2)
      end
      if strictImage then
        if #image[i][1] ~= w then
          error("Image must be same width as button",2)
        end
      end
    end
    local mX,mY = term.getCursorPos()
    if image then -- If a blit table is passed, loop through it and draw it.
      for i=1,image do
        local frame = image[i]
        term.setCursorPos(x,y+i-1)
        term.blit(frame[1],frame[2],frame[3])
      end
    term.setCursorPos(mX,mY)
    end
  end
end

--- Draw every button, this loops through the buttons table.
local function drawButtons()
  for k in pairs(buttons) do
    drawButton(k)
  end
end

--- Edit a button, changing it's function, position, or whatnot.
-- @tparam string id ID of the button to change.
-- @tparam[opt] number x X coordinate of the button.
-- @tparam[opt] number y Y coordinate of the button.
-- @tparam[opt] number width Width of the button.
-- @tparam[opt] number height Height of the button.
-- @tparam[opt] function func Function to execute when the button is clicked.
-- @tparam[opt] table image Table of blit lines to draw where the button is.
local function edit(id,x,y,w,h,func,image)
  expect(1,id,"string")
  expect(2,x,"number","nil")
  expect(3,y,"number","nil")
  expect(4,w,"number","nil")
  expect(5,h,"number","nil")
  expect(6,func"function","nil")
  expect(7,image,"table","nil")
  if not buttons[id] then
    error("Button " .. id .. " does not exist.",2)
  end
  x = x or buttons[id].x
  y = y or buttons[id].y
  w = w or buttons[id].w
  h = h or buttons[id].h
  local fFunc = func or buttons[id].fFunc
  local tDraw = image or buttons[id].tDraw
  local enabled = buttons[id].enabled
  buttons[id] = {
    x = x,
    y = y,
    w = w,
    h = h,
    fFunc = fFunc,
    tDraw = tDraw,
    enabled = enabled,
  }
end

local aliases = {
  newButton = new,
  deleteButton = delete,
  enableButton = enable,
  executeButtons = exec,
  execute = exec,
  editButton = edit,
}

return setmetatable({
  new = new,
  delete = delete,
  enable = enable,
  edit = edit,
  exec = exec,
  drawButton = drawButton,
  drawButtons = drawButtons,
},{__index = aliases})
