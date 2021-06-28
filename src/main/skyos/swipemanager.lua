--- Takes `mouse_click` and `mouse_drag` events and converts them into a `swipe` event.
-- @module[kind=skyos] swipeman

--- Table that converts a normalized vector into swipe directions.
local swipeDirections = setmetatable({
  [-1] = {[0] = "left"},
  [1] = {[0] = "right"},
  [0] = {[-1] = "up",[1] = "down"},
},{__index = function() return "unknown" end})

--- Run the swipe manager, with an optional debug variable.
-- @tparam[opt=false] boolean debug Whether or not debug messages are printed to the screen. Defaults to false.
local function run(debug)
  debug = debug or false
  while true do
    local e1 = {os.pullEvent()}
    if e1[1] == "mouse_click" then
      local event = os.pullEvent() -- Apparently theres also a `mouse_drag` queued in the same cell as the `mouse_click`. Bruh.
      if event == "mouse_drag" then
        local e2 = {os.pullEvent()}
        if e1[1] == "mouse_click" and e2[1] == "mouse_drag" then -- We gots a swipe!
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

return {
  swipeDirections = swipeDirections,
  run = run
}