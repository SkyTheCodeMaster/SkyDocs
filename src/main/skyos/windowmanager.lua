--- The window manager for SkyOS. Lets you start a file or function, with a visible or invisible window. 
-- This also has functions to set the active window.
-- This API will be globalized as `SkyOS.window`, and windows will be stored in `SkyOS.window.wins`, numerically indexed with the returned window id.
-- @module[kind=skyos] windowman

local expect = require("cc.expect").expect
local make_package = require("cc.require").make

-- Next window number 
local nextWin = 1

--- Currently active widnow, index `wins` with this.
local activeWindow = 0
--- Windows that currently exist(and are running)
local wins = {} 

--- Whether or not the top bar is open.
local topbarOpen = true
--- Whether or not the bottom bar is open.
local bottombarOpen = true

-- Localize global apis.
local window = window

-- Create an environment, with `term` replaced with a supplied window object, also with a `self` variable with stuff like the window, coro pid, etc
local function makeProgramEnv(custEnv,win)
  custEnv = custEnv or {}
  local myEnv = setmetatable({},{__index=_G})
  for k,v in pairs(custEnv) do
    myEnv[k] = v
  end
  myEnv["term"] = win

  local native = _G.term.native and _G.term.native() or term
  local redirectTarget = native

  local function wrap(_sFunction)
    return function(...)
      return redirectTarget[_sFunction](...)
    end
  end

  myEnv["term"]["current"] = function() return redirectTarget end
  myEnv["term"]["redirect"] = function(target)
    expect(1, target, "table")
    if target == myEnv["term"] or target == _G.term then
      error("term is not a recommended redirect target, try term.current() instead", 2)
    end
    for k, v in pairs(native) do
      if type(k) == "string" and type(v) == "function" then
        if type(target[k]) ~= "function" then
          target[k] = function()
            error("Redirect object is missing method " .. k .. ".", 2)
          end
        end
      end
    end
    local oldRedirectTarget = redirectTarget
    redirectTarget = target
    return oldRedirectTarget
  end

  local term = myEnv["term"]
  for k,v in pairs(native) do
    if type(k) == "string" and type(v) == "function" and rawget(term,k) == nil then
      myEnv["term"][k] = wrap(k)
    end
  end

  myEnv["term"]["native"] = function() return native end

  myEnv["SkyOS"] = setmetatable({
    ["self"] = {win = win},
    ["close"] = function() end,
    ["visible"] = function(isVisible) return isVisible end,
    ["back"] = function() end,
  },{__index=_G.SkyOS})
  myEnv["require"],myEnv["package"] = make_package(myEnv,"/")
  return myEnv
end

--- Create a new window with a function to run 
-- The table resulting from this function (stored in `SkyOS.window.wins`) will be indexed key/value with the window's id. The table will look like this:
-- win.pid is a number containing the coroutine pid, used to terminating, pausing, etc of the window. 
-- win.win is a table with the actual window object. this is a mirror of win.env.term.
-- win.env is the environment of the window, with all of it's values.
-- @tparam string program Path to program to run.
-- @tparam[opt] string name Name to call the program (passed to coroutine manager). Defaults to the name of the program.
-- @tparam[opt] boolean visible Whether or not this process is visible. Defaults to false.
-- @tparam[opt] table env Environment to pass to function/program. Defaults to _ENV.
-- @param ... Arguments to pass to the function/program.
-- @treturn number Window ID of the window, interface it with `SkyOS.window.wins[id]`.
local function newWindow(program,name,visible,env,...)
  expect(1,program,"function","string")
  expect(2,name,"string","nil")
  expect(3,visible,"boolean","nil")
  expect(4,env,"table","nil")
  env = env or _ENV
  name = name or fs.getName(program)
  if not fs.exists(program) then
    error("Program not found",2)
  end
  -- We want to start it in 26x18 mode, which is the default with both bars visible.
  local win = window.create(term.current(),1,2,26,18,visible)
  local programEnv = makeProgramEnv(env,win)
  local tArgs = table.pack(...)
  local f = fs.open(program,"r")
  local contents = f.readAll()
  f.close()
  local func = load(contents,"="..name,"t",programEnv)
  local function runFunc()
    func(table.unpack(tArgs,1,tArgs.n))
  end
  local pid = SkyOS.coro.newCoro(runFunc,name)
  programEnv["SkyOS"]["self"]["pid"] = pid
  programEnv["SkyOS"]["self"]["winid"] = nextWin
  programEnv["SkyOS"]["self"]["path"] = function() return fs.getDir(program) end
  -- Now create the table to stick into the wins table
  local winTable = {
    win = win,
    env = programEnv,
    pid = pid,
  }
  wins[nextWin] = winTable
  nextWin = nextWin + 1
  return nextWin-1
end

--- Close a window, it calls `SkyOS.close()` and then kills the process.
-- @tparam table win Window, pull from `SkyOS.window.wins`.
local function closeWindow(win)
  expect(1,win,"table")
  if win.env.SkyOS.close then
    win.env.SkyOS.close()
  end
  SkyOS.coro.killCoro(win.env.SkyOS.self.pid)
  wins[win.env.SkyOS.self.winid] = nil
end

--- Bring a window to the foreground, also calls the `SkyOS.visible(isVisible)` callback functions.
-- @tparam table|number window Window table or ID to bring to the front.
local function foreground(win)
  local id
  if type(win) == "table" then
    -- Now loop through the `wins` table to find it.
    local found = false
    for k,v in pairs(wins) do
      if not found and v == win then
        id = k
        found = true
      end
    end
    if not found then error("Window not found!",2) end
  elseif type(win) == "number" and wins[win] then
    id = win
  else 
    error("Window not found!",2)
  end
  -- Remove the old window and coro from being active
  if wins[activeWindow] then -- This only happens on first boot, but still a good check.
    local oldWin = activeWindow
    SkyOS.coro.activeCoros[wins[oldWin].pid] = false
    wins[oldWin].env.SkyOS.visible(false)
    wins[oldWin].self.env.term.setVisible(false) -- `term` is actually a window object, here.
  end
  activeWindow = id
  SkyOS.coro.activeCoros[wins[id].pid] = true
  wins[id].env.SkyOS.visible(true)
  wins[id].env.term.setVisible(true)

  -- That's about it.
end

return {
  wins = wins,
  activeWindow = activeWindow,
  bottombarOpen = bottombarOpen,
  topbarOpen = topbarOpen,
  newWindow = newWindow,
  closeWindow = closeWindow,
  foreground = foreground,
}