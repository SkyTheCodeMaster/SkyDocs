--- Takes various mouse events, and converts them into other events, such as long press, pan, and swipe.
-- @module[kind=skyos] gestures

local coro = dofile("libraries/coro.lua")

--- How long (in milliseconds) a tap must be help for to qualify as a "long press".
local pressDelay = SkyOS.settings.longPressDelay or 1000 -- Default 1000 milliseconds for long press

--- Table that converts a normalized vector into swipe directions.
local swipeDirections = setmetatable({
  [-1] = {[0] = "left"},
  [1] = {[0] = "right"},
  [0] = {[-1] = "up",[1] = "down"},
},{__index = function() return "unknown" end})


--- Run the swipe manager, with an optional debug variable.
-- @tparam[opt=false] boolean debug Whether or not debug messages are printed to the screen. Defaults to false.
local function swipe(debug)
  debug = debug or false
  while true do
    local e1 = {os.pullEvent()}
    if e1[1] == "mouse_click" then
      local event = os.pullEvent() -- Apparently theres also a `mouse_drag` queued in the same cell as the `mouse_click`. Bruh.
      if event == "mouse_drag" then
        local e2 = {os.pullEvent()}
        if e1[1] == "mouse_click" and e2[1] == "mouse_drag" and e1[2] == e2[2] then -- We gots a swipe!
          -- Calculate vectors
          local start = vector.new(e1[3],e1[4])
          local swipeEnd = vector.new(e2[3],e2[4])
          local direction = (swipeEnd-start):normalize()
          if debug then
            print("click",e1[3],e1[4])
            print("drag",e2[3],e2[4])
            print("normal",direction.x,direction.y)
          end
          local strDirection = swipeDirections[direction.x][direction.y]
          if debug then
            print("swipe",strDirection)
          end
          if strDirection and strDirection ~= "unknown" then
            os.queueEvent("swipe",strDirection)
          end
        end
      end
    end
  end
end

--- Run the long press manager, with an optional debug variable.
-- @tparam[opt=false] boolean debug Whether or not debug messages are printed to the screen. Defaults to false.
local function longPress(debug)
  debug = debug or false
  while true do
    local _,cm,cx,cy = os.pullEvent("mouse_click")
    local startTime = os.epoch("utc")
    if debug then print("click",cm,cx,cy,startTime) end
    local _,m,x,y = os.pullEvent("mouse_up")
    local endTime = os.epoch("utc")
    if debug then print("up",m,x,y,endTime,endTime-startTime) end
    if endTime - startTime >= pressDelay and cm == m and cx == x and cy == y then
      os.queueEvent("long_press",m,x,y)
    end
  end
end

--- Run the `pan` event, which is triggered when the user is dragging on the screen.
-- @tparam[opt=false] boolean debug Whether or not debug messages are printed to the screen. Defaults to false.
local function pan(debug)
  debug = debug or false
  while true do
    local _,cm,cx,cy = os.pullEvent("mouse_drag")
    local _,m,x,y = os.pullEvent("mouse_drag")
    if cm == m then
      -- Calculate vectors
      local vStart = vector.new(cx,cy)
      local vEnd = vector.new(x,y)
      local vNormal = (vEnd-vStart):normalize()
      if debug then
        print("drag1",cx,cy)
        print("drag2",x,y)
        print("normal",vNormal.x,vNormal.y)
      end
      local strDirection = swipeDirections[vNormal.x][vNormal.y]
      if debug then
        print("swipe",strDirection)
      end
      if strDirection and strDirection ~= "unknown" then
        os.queueEvent("pan",strDirection)
      end
    end
  end
end

--- Run the pan_up manager, which is triggered when a pan event stops happening, and includes the total distance moved with an optional debug variable.
-- @tparam[opt=false] boolean debug Whether or not debug messages are printed to the screen. Defaults to false.
local function pan_up(debug)
  debug = debug or false
  while true do
    local _,cm,cx,cy = os.pullEvent("mouse_click")
    if debug then print("click",cm,cx,cy) end
    local _,m,x,y = os.pullEvent("mouse_up")
    if debug then print("up",m,x,y) end
    if cm == m and cx ~= x and cy ~= y then
      -- Now calculate the difference
      local difX,difY = x-cx,y-cy
      if debug then print("pan",m,difX,difY) end
      os.queueEvent("pan_up",m,difX,difY)
    end
  end
end

--- Run all gesture functions. This just simply calls them all.
local function run()
  coro.newCoro(swipe,"Swipe Manager",nil,nil,true)
  coro.newCoro(longPress,"Long Press",nil,nil,true)
  coro.newCoro(pan,"Pan Manager",nil,nil,true)
  coro.newCoro(pan_up,"Pan Up Manager",nil,nil,true)
  coro.runCoros()
end

--- Stop the gesture functions, can be restarted by calling `run` again.
local function stop()
  coro.stop()
  coro.coros = {}
end

return {
  swipeDirections = swipeDirections,
  run = run,
  stop = stop,
  swipe = swipe,
  longPress = longPress,
  pan = pan,
  pan_up = pan_up,
}