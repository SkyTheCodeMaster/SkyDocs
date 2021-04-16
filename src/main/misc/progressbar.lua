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

local function dfb(x,y,w,h,col) -- draw filled box
  local tbl = save()
  paintutils.drawFilledBox(x,y,w,h,col)
  restore(tbl)
end

local function update(bar,percent)
  -- Calculate pixel requirements
  if percent > 100 then percent = 100 end
  local pixels = math.floor((percent / (100 / bar.w)) + 0.5) -- The math.floor + 0.5 acts as a rounding function.
  -- percent / (100 / barWidth) calculates how many pixels should be filled in the bar
  dfb(bar.x,bar.y,(bar.x+bar.w),(bar.y+bar.h),bar.bg)
  if pixels ~= 0 then
    dfb(bar.x,bar.y,(bar.x+pixels),(bar.y+bar.h),bar.fg)
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
local function create(x,y,w,h,fg,bg,fill)
  fill = fill or 0
  local bar = {
    x = x,
    y = y,
    w = w,
    h = h,
    fg = fg,
    bg = bg,
    fill = fill,
  }
  if fill ~= 0 then update(bar,fill) end
  return setmetatable(bar,mt)
end

return {
  create = create,
}
