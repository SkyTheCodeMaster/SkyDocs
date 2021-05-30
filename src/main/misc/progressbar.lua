--- progress bar is an api for drawing & updating progress bars.
-- @module[kind=misc] progressbar

local function save()
  local x,y = term.getCursorPos()
  local tbl = {
    fg = term.getTextColour(),
    bg = term.getBackgroundColour(),
    x = x,
    y = y,
  }
  return tbl
end

local function restore(tbl)
  term.setCursorPos(tbl.x,tbl.y)
  term.setTextColour(tbl.fg)
  term.setBackgroundColour(tbl.bg)
end

-- Soort coordinates. ex: 34,2 -> 21,34. (Sorts the x/y coordinates)
-- This function is written w/ paintutils' one in mind, so it acts similar.
local function sort(x,y,w,h)
  local lowX,highX,lowY,highY
  -- If the width is smaller than x, swap em around
  if w <= x then
    lowX = w
    highX = x
  else -- Leave them be 
    lowX = x
    highX = w
  end
  -- Do the same, but for height
  if h <= y then
    lowY = h
    highY = y
  else -- Leave them be 
    lowY = y 
    highY = h
  end
  return lowX,highX,lowY,highY
end

-- draw filled box
local function dfb(x,y,w,h,col,tOutput) 
  local tbl = save()
  x,w,y,h = sort(x,y,w,h)
  local width = x - w + 1
  -- Pretty simple, just fills in the space
  for o = y,h do
    tOutput.setCursorPos(x,o)
    tOutput.blit((" "):rep(width),("f"):rep(width),(colours.toBlit(col)):rep(width))
  end
  restore(tbl)
end

local function update(bar,percent)
  -- Calculate pixel requirements
  if percent > 100 then percent = 100 end
  local pixels = math.floor((percent / (100 / bar.w)) + 0.5) -- The math.floor + 0.5 acts as a rounding function.
  -- percent / (100 / barWidth) calculates how many pixels should be filled in the bar
  dfb(bar.x,bar.y,(bar.x+bar.w),(bar.y+bar.h),bar.bg,bar.terminal)
  if pixels ~= 0 then
    dfb(bar.x,bar.y,(bar.x+pixels),(bar.y+bar.h),bar.fg,bar.terminal)
  end
  return percent
end

local bar = {} --- @type bar
local mt = {["__index"] = bar}

--- Update the bar to a percentage from 0 to 100.
-- @tparam number percent Percentage of how full the bar is.
function bar:update(percent)
  self.fill = update(self,percent)
end

--- Redraw the bar, putting it overtop of whatever has been drawn since.
function bar:redraw()
  update(self,self.fill)
end

--- Create a bar object
-- @tparam number x X coordinate of the bar.
-- @tparam number y Y coordinate of the bar.
-- @tparam number w Width of the bar.
-- @tparam number h Height of the bar.
-- @tparam number fg The colour of the filled in bar.
-- @tparam number bg The colour of the background of the bar.
-- @tparam[opt] number fill The pre filled portion of the bar. Defaults to 0.
-- @tparam[opt] table terminal The terminal to draw the bar on. Defaults to `term.current()`.
local function create(x,y,w,h,fg,bg,fill,terminal)
  fill = fill or 0
  terminal = terminal or term.current()
  local bar = {
    x = x,
    y = y,
    w = w,
    h = h,
    fg = fg,
    bg = bg,
    fill = fill,
    terminal = terminal,
  }
  if fill ~= 0 then update(bar,fill) end
  return setmetatable(bar,mt)
end

return {
  create = create,
}
