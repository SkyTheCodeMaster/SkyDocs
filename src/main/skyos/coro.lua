--- Coroutine manager for SkyOS. Might work, might not, who knows.
-- @module[kind=skyos] coro

local ok,crash = pcall(require,"libraries.crash") -- Crash reporting!
if not ok then crash = function(x,y) end end -- Override crash function if crash library is not available/is errored

-- Localize coroutine library, because it gets used quite a bit, surprisingly.
local coroutine = coroutine

--- Currently active coroutines, with pid as key.
local activeCoros = {}

--- Check if a coroutine is active
-- @tparam table coro Coroutine table to check.
-- @treturn boolean Whether or not the coroutine is active.
local function isActive(coroTable)
  if activeCoros[coroTable.pid] then return true end -- Check if coroutine itself is active.
  if activeCoros[coroTable.parent] then return true end -- Check if coroutine's parent is active.
  return coroTable.forceActive -- Finally, just return it's force active status. either nil or true. (or any other truthy/falsey value)
end
--- Currently running coroutines. This is stored in `SkyOS.coro.coros`
local coros = {}

--- The amount of processes that have been created.
local pids = 0

local running = true

--- Events that are blocked for non active coroutines. (aka not on top)
local blocked = {
  ["mouse_click"] = true,
  ["mouse_drag"] = true,
  ["mouse_scroll"] = true,
  ["mouse_up"] = true, 
  ["paste"] = true,
  ["key"] = true,
  ["key_up"] = true,
  ["char"] = true
}

--- Make a new coroutine and add it to the currently running list.
-- @tparam function func Function to run forever.
-- @tparam[opt] string name Name of the coroutine, defaults to `coro`.
-- @tparam[opt] number parent Parent PID, mirrors it's active state.
-- @tparam[opt] table env Custom environment to use for coroutine, defaults to `_ENV`.
-- @tparam[opt] boolean forceActive Whether or not this coroutine will always have user events.
-- @treturn number PID of the coroutine. This shouldn't change.
local function newCoro(func,name,parent,forceActive)
  local pid = pids + 1
  pids = pid
  table.insert(coros,{coro=coroutine.create(func),filter=nil,name=name or "coro",pid = pid,parent=parent,forceActive = forceActive})
  return pid
end 

--- Kill a coroutine, and remove it from the coroutine table.
-- @param coro Coroutine to kill, accepts a number (index in table) or a string (name of coroutine).
local function killCoro(coro)
  if type(coro) == "number" then
    if coros[coro] then coros[coro] = nil end
  elseif type(coro) == "string" then
    for i=1,#coros do
      if coros[i].name == coro then
        coros[i] = nil
        break
      end
    end
  end
end

--- Run the coroutines. This doesn't take any parameters nor does it return any.
local function runCoros()
  local e = {n = 0}
  while running do
    for k,v in pairs(coros) do
      if coroutine.status(v.coro) == "dead" then
        coros[k] = nil
      else
        if not v.filter or v.filter == e[1] then -- If unfiltered, pass all events, if filtered, pass only filter
          -- Check for active coroutine
          if isActive(v) or not blocked[e[1]] then
            local ok,filter = coroutine.resume(v.coro,table.unpack(e))
            if ok then
              v.filter = filter -- okie dokie
            else
              local traceback = debug.traceback(v.coro)
              crash(traceback,filter)
              if SkyOS then -- We be inside of SkyOS environment
                SkyOS.displayError(v.name .. ":" .. filter .. ":" .. debug.traceback(v.coro))
              else 
                error(filter)
              end
            end
          end
        end
      end
    end
    e = table.pack(coroutine.yield())
  end
  running = true
end

--- Stop the coroutine manager, halting all threads after current loop. Note that this will not stop it immediately.
local function stop()
  running = false
end

return {
  coros = coros,
  activeCoros = activeCoros,
  newCoro = newCoro,
  killCoro = killCoro,
  runCoros = runCoros,
  stop = stop,
}