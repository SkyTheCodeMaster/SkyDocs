--- The window manager for SkyOS. Lets you start a file or function, with a visible or invisible window. 
-- This also has functions to set active window, show/hide notification bar and bottom button bar.
-- This API will be globalized as `SkyOS.window`, and windows will be stored in `SkyOS.window.wins`, numerically indexed with the returned window id.
-- @module[kind=skyos] windowman

local expect = require("cc.expect").expect

-- Next window number 
local nextWin = 1
-- Windows 
local wins = {} 
-- Top bar open 
local topBarOpen = true
local bottomBarOpen = true

-- Localize global apis.
local window = window

--- Create a new window with a function to run 
-- @tparam function|string program Either a path to a program, or a function to run.
-- @tparam string name Name to call the program (passed to coroutine manager).
-- @tparam boolean visible Whether or not this process is visible.
-- @param ... Arguments to pass to the function/program.
local function newWindow(program,name,visible,...)
  expect(1,program,"function","string")
  expect(2,name,"string")
  expect(3,visible,"boolean")
  local tArgs = table.pack(...)
  local func
  if type(program) == "function" then
    func = program
  elseif type(program) == "string" and fs.exists(program) then
    local f = fs.open(program,"r")
    local contents = f.readAll()
    f.close()
    func = load(contents,name,"t",_ENV)
  end
  local function runFunc()
    func(table.unpack(tArgs,1,tArgs.n))
  end

end

return {
  wins = wins,
  topBarOpen = topBarOpen,
  bottomBarOpen = bottomBarOpen,
  newWindow = newWindow,
}