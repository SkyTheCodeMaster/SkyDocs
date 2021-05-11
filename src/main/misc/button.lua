--- A simple button api with the option of drawing an image on the button.
-- @module[kind=misc] button

local expect = require("cc.expect").expect
--- idLength is how long the specific IDs are, if you have lots of buttons, this should go higher.
local idLength = 6 -- This is the length of the unique identifiers for buttons.
--- strictImage forces the image to be the same height and width as the button
local strictImage = true -- This confirms that the image is the same height as the button.
local buttons = {}

local function genRandID(length)
  local str = ""
  for i=1,length do
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
]]
local function newButton(nX,nY,nW,nH,fFunc,tDraw,enabled) -- tDraw is a table of blit lines. This function will check they're the same length.
  expect(1,nX,"number")
  expect(1,nY,"number")
  expect(1,nW,"number")
  expect(1,nH,"number")
  expect(1,fFunc,"function")
  expect(1,tDraw,"table","nil")
  expect(1,enabled,"boolean","nil")
  enabled = enabled or true -- retain old behaviour

  local mX,mY = term.getCursorPos()

  if tDraw then -- If a blit table is passed, loop through it and make sure it's a valid (ish) table, and make sure it's the same height & width as the button.
    if strictImage then
      if #tDraw ~= nH then
        error("Image must be same height as button")
      end
    end
    for i=1,#tDraw do
      if #tDraw[i][1] ~= #tDraw[i][2] or #tDraw[i][1] ~= #tDraw[i][3] then
        error("tDraw line" .. tostring(i) .. "is not equal to other lines")
      end
      if strictImage then
        if #tDraw[i][1] ~= nW then
          error("Image must be same width as button")
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
      term.setCursorPos(nX,nY+i)
      term.blit(frame[1],frame[2],frame[3])
    end
  term.setCursorPos(mX,mY)
  end

  return id
end

--- Remove a button from being clicked.
-- @tparam string id button id to remove.
local function deleteButton(id) -- This doesn't remove the image if any!
  if buttons[id] then
    buttons[id] = nil
  end
end

--- Enable or disable a button.
-- @tparam string id Button to enable or disable.
-- @tparam boolean enable Whether the button is enabled or not.
local function enableButton(id,enable)
  if not buttons[id] then error("Button " .. id .. " does not exist.") end
  buttons[id].enabled = enable
end

--- Takes an event, checks if it's a `mouse_click` or `mouse_drag`, and sees if it's within a button.
-- @tparam table event Event table to check for `mouse_click` or `mouse_drag`.
-- @tparam[opt] boolean drag Enable button trigger on a `mouse_drag` event. Defaults to false.
local function executeButtons(tEvent,bDrag)
  bDrag = bDrag or false
  if tEvent[1] == "mouse_click" or (bDrag and tEvent[1] == "mouse_drag") then
    local x,y = tEvent[3],tEvent[4]
    for i,v in pairs(buttons) do
      if v.enabled and x >= v.x and x <= v.x + v.w - 1 and y >= v.y and y <= v.y + v.h - 1 then
        v.fFunc()
      end
    end
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
  if not buttons[id] then
    error("Button " .. id .. " does not exist.")
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

return {
  newButton = newButton,
  deleteButton = deleteButton,
  enableButton = enableButton,
  edit = edit,
  executeButtons = executeButtons,
}
