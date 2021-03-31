--- The graphic library is a wrapper around paintutils.
-- @module[kind=skyos] graphic

local graphic = {}
 
-- Graphics library for SkyOS
 
local to_colors, to_blit = {}, {}
for i = 1, 16 do
    to_blit[2^(i-1)] = ("0123456789abcdef"):sub(i, i)
    to_colors[("0123456789abcdef"):sub(i, i)] = 2^(i-1)
end

--- drawFilledBox draws a filled in box at the specified coordinates
-- @tparam number x topleft x coordinate of the box
-- @tparam number y topleft y coordinate of the box
-- @tparam number x2 bottomright x coordinate of the box
-- @tparam number y2 bottomright y coordinate of the box
-- @tparam number colour colour of the box
-- @tparam table output output terminal of the box
function graphic.drawFilledBox(nX1,nY1,nX2,nY2,nC,tOutput)
  tOutput = tOutput or term.current()
  local currentX,currentY = tOutput.getCursorPos()
  local col = to_blit[nC]
  local w = (tonumber(nX2)-tonumber(nX1))+1
  for i=tonumber(nY1),tonumber(nY2) do
    tOutput.setCursorPos(tonumber(nX1),i)
    tOutput.blit(string.rep(" ",w),string.rep(col,w),string.rep(col,w))
  end
  tOutput.setCursorPos(currentX,currentY)
end

--- drawBox draws a hollow box at the specified coordinates
-- @tparam number x topleft x coordinate of the box
-- @tparam number y topleft y coordinate of the box
-- @tparam number x2 bottomright x coordinate of the box
-- @tparam number y2 bottomright y coordinate of the box
-- @tparam number colour colour of the box
-- @tparam table output output terminal of the box
function graphic.drawBox(nX1,nY1,nX2,nY2,nC,tOutput)
  tOutput = tOutput or term.current()
  local nCurFG = tOutput.getTextColour()
  local nCurBG = tOutput.getBackgroundColour()
  local nCurX, nCurY = tOutput.getCursorPos()
  
  paintutils.drawBox(tonumber(nX1),tonumber(nY1),tonumber(nX2),tonumber(nY2),tonumber(nC),tOutput)
  
  tOutput.setCursorPos(nCurX,nCurY)
  tOutput.setTextColour(nCurFG)
  tOutput.setBackgroundColour(nCurBG)
end
 
--- drawPixel draws a single pixel at the specified coordinates
-- @tparam number x x coordinate of the pixel
-- @tparam number y y coordinate of the pixel
-- @tparam number colour colour of the pixel
-- @tparam table output output terminal of the pixel
function graphic.drawPixel(nX,nY,nC,tOutput)
  tOutput = tOutput or term.current()
  local nCurFG = tOutput.getTextColour()
  local nCurBG = tOutput.getBackgroundColour()
  local nCurX, nCurY = tOutput.getCursorPos()
  
  paintutils.drawPixel(tonumber(nX),tonumber(nY),tonumber(nC),tOutput)
  
  tOutput.setCursorPos(nCurX,nCurY)
  tOutput.setTextColour(nCurFG)
  tOutput.setBackgroundColour(nCurBG)
end
 
--- drawText draws a textline with set colours
-- @tparam number x x coordinate of the start of the text
-- @tparam number y y coordinate of the start of the text 
-- @tparam number fg colour of the text
-- @tparam number bg background colour of the text
-- @tparam string text the text to write
-- @tparam table output output terminal of the text
function graphic.drawText(nX,nY,nFG,nBG,sText,tOutput)
  tOutput = tOutput or term.current()
  local nCurFG = tOutput.getTextColour()
  local nCurBG = tOutput.getBackgroundColour()
  local nCurX, nCurY = tOutput.getCursorPos()
    
  tOutput.setCursorPos(tonumber(nX),tonumber(nY))
  tOutput.setTextColour(tonumber(nFG))
  tOutput.setBackgroundColour(tonumber(nBG))
  tOutput.write(sText)
    
  tOutput.setCursorPos(nCurX,nCurY)
  tOutput.setTextColour(nCurFG)
  tOutput.setBackgroundColour(nCurBG)
end

--- drawLine draws a line between the two coordinates
-- @tparam number x1 x coordinate of one end 
-- @tparam number y2 y coordinate of one end
-- @tparam number x2 x coordinate of the other end 
-- @tparam number y2 y coordinate of the other end 
-- @tparam number colour colour of the line
-- @tparam table output output terminal of the line
function graphic.drawLine(nX1, nY1, nX2, nY2, nCol, tOutput)
  tOutput = tOutput or term.current()
  local nCurFG = tOutput.getTextColour()
  local nCurBG = tOutput.getBackgroundColour()
  local nCurX, nCurY = tOutput.getCursorPos()
 
  paintutils.drawLine(tonumber(nX1),tonumber(nY1),tonumber(nX2),tonumber(nY2),tonumber(nCol))
 
  tOutput.setCursorPos(nCurX,nCurY)
  tOutput.setTextColour(nCurFG)
  tOutput.setBackgroundColour(nCurBG)
end

return graphic