--- progress bar is an api for drawing & updating progress bars.
-- @module[kind=skyos] progressbar

local progressBar = {}

if not fs.exists("libraries/graphic.lua") then
  local h,err = http.get("https://raw.githubusercontent.com/SkyTheCodeMaster/SkyOS/master/libraries/graphic.lua")
  if not h then error(err) end
  local f = fs.open("libraries/graphic.lua","w")
  f.write(h.readAll())
  f.close()
  h.close()
end

local graphic = require("libraries.graphic")

local bars = {}

-- fill or filled is a PERCENTAGE of how full the bar is.

local function calcFill(len,fill)

  if fill > 100 then fill = 100 end
  local div = 100 / len
  local result = math.floor((fill / div) + 0.5)
  
  return result

end

--- updateStep updates a progress bar by it's steps
-- @tparam string name name of the bar to update
-- @tparam number step current step out of the total steps
-- @tparam number total total steps of the progress bar
function progressBar.updateStep(name,step,total)
  local percent = (step/total) * 100
  progressBar.update(name,percent)
end

--- update updates a progress bar by a percentage 
-- @tparam string name name of the bar to update
-- @tparam number percentage percentage of the barto fill
function progressBar.update(name,filled)
  if not bars[name] then error("bar does not exist") end
  local tableBar = bars[name]

  local _,len,x,y,fg,bg,tOutput = tableBar[1],tableBar[2],tableBar[3],tableBar[4],tableBar[5],tableBar[6],tableBar[7]
  local pixels = calcFill(len,filled)

  graphic.drawFilledBox(x,y,len,y,bg,tOutput) -- draw over the old progess bar - useful if progress goes backwards
  graphic.drawFilledBox(x,y,pixels,y,fg,tOutput)
  bars[name] = {filled, len, x, y, fg, bg, tOutput}
end

--- new creates a new bar
-- @tparam number x x coordinate of the bar
-- @tparam number y y coordinate of the bar
-- @tparam number length length of the bar
-- @tparam number fg colour of the filled in bar
-- @tparam number bg background colour of the bar
-- @tparam string name name of the bar
-- @tparam number filled pre filled portion of the bar
-- @tparam table output output terminal of the bar
function progressBar.new(x,y,len,fg,bg,name,filled,tOutput)
  tOutput = tOutput or term.current()
  filled = filled or 0

  graphic.drawFilledBox(x,y,len,y,bg,tOutput) -- draw the background of it

  bars[name] = {filled, len, x, y, fg, bg, tOutput}

  if filled ~= 0 then
    progressBar.update(name,filled,tOutput) -- if `filled` variable is passed, fill the progress bar to that amount.
  end

  return name
end

function progressBar.getFill(name)
  if not bars[name] then error("bar does not exist") end

  local tableBar = bars[name]
  
  return tableBar[1]
end

function progressBar.get(name)
  if not bars[name] then error("bar does not exist") end
  return bars[name]
end

return progressBar