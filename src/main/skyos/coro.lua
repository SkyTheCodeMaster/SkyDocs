--- Coroutine manager for SkyOS. Might work, might not, who knows.
-- @module[kind=skyos] coro

--- Currently running coroutines. This is stored in `SkyOS.coro.coros`
local coros = {}

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
  while true do
    local e = {os.pullEventRaw()}
    for i=1,#coros do
      if coroutine.status(coros[i].coro) == "dead" then
        table.remove(coros,i)
      else
        if not coros[i].filter or coros[i].filter == e[1] or e[1] == "terminate" then -- If unfiltered, pass all events, if filtered, pass only filter
          local ok,filter = coroutine.resume(coros[i].coro,table.unpack(e))
          if ok then
            coros[i].filter = filter -- okie dokie
          else
            if SkyOS then -- We be inside of SkyOS environment
              SkyOS.displayError(coros[i].name .. ": " .. filter)
            else 
              error(filter)
            end
          end
        end
      end
    end 
  end 
end

return {
  coros = coros,
  newCoro = newCoro,
  killCoro = killCoro,
  runCoros = runCoros,
}