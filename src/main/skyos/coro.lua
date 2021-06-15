--- Coroutine manager for SkyOS. Might work, might not, who knows.
-- @module[kind=skyos] coro

--- Currently running coroutines. This is stored in `SkyOS.coro.coros`
local coros = {}

local running = true

--- Make a new coroutine and add it to the currently running list.
-- @tparam function func Function to run forever.
-- @tparam[opt] string name Name of the coroutine, defaults to `coro`.
-- @treturn number PID of the coroutine. Subject to change :).
local function newCoro(func,name)
  table.insert(coros,{coro=coroutine.create(func),filter=nil,name=name or "coro"})
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
  while running do
    local e = {os.pullEventRaw()}
    for k,v in pairs(coros) do
      if coroutine.status(v.coro) == "dead" then
        table.remove(coros,k)
      else
        if not v.filter or v.filter == e[1] or e[1] == "terminate" then -- If unfiltered, pass all events, if filtered, pass only filter
          local ok,filter = coroutine.resume(v.coro,table.unpack(e))
          if ok then
            v.filter = filter -- okie dokie
          else
            if SkyOS then -- We be inside of SkyOS environment
              SkyOS.displayError(v.name .. ": " .. debug.traceback(v.coro))
            else 
              error(filter)
            end
          end
        end
      end
    end 
    os.queueEvent("coro_yield")
  end
  running = true
end

--- Stop the coroutine manager, halting all threads after current loop. Note that this will not stop it immediately.
local function stop()
  running = false
end

return {
  coros = coros,
  newCoro = newCoro,
  killCoro = killCoro,
  runCoros = runCoros,
  stop = stop,
}