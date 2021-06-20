--[[MIT License

Copyright (c) 2021 SkyCrafter0

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.]]

-- Get all the shit for bein online
local h,err = http.get("https://raw.githubusercontent.com/SkyTheCodeMaster/SkyDocs/fdf3d62fcbdaa39a957f7a074ebef95bff4a79a1/src/main/misc/sUtils.lua")
if err then error("Something went wrong whilst downloading sUtils!") end
local content = h.readAll() h.close()
local sUtils = load(content,"=prewebquire-package","t",_ENV)()
local button = sUtils.webquire("https://raw.githubusercontent.com/SkyTheCodeMaster/SkyDocs/ddec75606d183c743c9a92bd08d28b60f8caae3a/src/main/misc/button.lua")
local paintutils = sUtils.webquire("https://skydocs.madefor.cc/scriptdata/paintutils.lua") -- paintutils is always online :D

--[[
  Standard `.skimg` attributes tablelib
  {
    width = 26,
    height = 20,
    creator = "SkyCrafter0",
    locked = false,
    
  }
]]

-- localize some APIs, make it faster to call them.
local term = term
local fs = fs
local colours = colours
local window = window

local data = {
  bgColour = colours.black,
  textColour = colours.white,
  promptColour = colours.yellow,
  blitToWord = {
    ["0"] = "White",
    ["1"] = "Orange",
    ["2"] = "Magenta",
    ["3"] = "Light Blue",
    ["4"] = "Yellow",
    ["5"] = "Lime",
    ["6"] = "Pink",
    ["7"] = "Grey",
    ["8"] = "Light Grey",
    ["9"] = "Cyan",
    ["a"] = "Purple",
    ["b"] = "Blue",
    ["c"] = "Brown",
    ["d"] = "Green",
    ["e"] = "Red",
    ["f"] = "Black",
  }
}

local assets = {
  colours = {
    attributes = {
      width = 4,
      height = 4,
      creator = "SkyCrafter0",
      locked = true,
    },
    data = {
      {"+-FG-+-BG-+","88888888888","00000000000",1},
      {"|    |    |","80000800008","00123001230",2},
      {"|    |    |","80000800008","04567045670",3},
      {"|    |    |","80000800008","089ab089ab0",4},
      {"|    |    |","80000800008","0cdef0cdef0",5},
      {"+----+----+","88888888888","00000000000",6}
    }
  },
  col = {
    "0123",
    "4567",
    "89ab",
    "cdef",
  },
  resize = {
    {"Resize the canvas?","000000000000000000","777777777777777777",1},
    {"                  ","000000000000000000","777777777777777777",2},
    {"New X Dimension:  ","000000000000000000","777777777777777777",3},
    {"                  ","000000000000000000","777777777777777777",4},
    {"New Y Dimension:  ","000000000000000000","777777777777777777",5},
    {"                  ","                  ","777777777777777777",6},
  },
  fileMenu = {
    {"Redraw","000000","777777",1},
    {"Resize","000000","777777",2},
    {"Save  ","000000","777777",3},
    {"Exit  ","000000","777777",4},
  },
  characters = {
    attributes = {
      width = 8,
      height = 8,
      creator = "SkyCrafter0",
      locked = true,
    },
    data = {
      {"\0\1\2\3\4\5\6\7\8\9\10\11\12\13\14\15","0000000000000000","ffffffffffffffff",1},
      {"\16\17\18\19\20\21\22\23\24\25\26\27\28\29\30\31","0000000000000000","ffffffffffffffff",2},
      {"\32\33\34\35\36\37\38\39\40\41\42\43\44\45\46\47","0000000000000000","ffffffffffffffff",3},
      {"\48\49\50\51\52\53\54\55\56\57\58\59\60\61\62\63","0000000000000000","ffffffffffffffff",4},
      {"\64\65\66\67\68\69\70\71\72\73\74\75\76\77\78\79","0000000000000000","ffffffffffffffff",5},
      {"\80\81\82\83\84\85\86\87\88\89\90\91\92\93\94\95","0000000000000000","ffffffffffffffff",6},
      {"\96\97\98\99\100\101\102\103\104\105\106\107\108\109\110\111","0000000000000000","ffffffffffffffff",7},
      {"\112\113\114\115\116\117\118\119\120\121\122\123\124\125\126\127","0000000000000000","ffffffffffffffff",8},
      {"\128\129\130\131\132\133\134\135\136\137\138\139\140\141\142\143","0000000000000000","ffffffffffffffff",9},
      {"\144\145\146\147\148\149\150\151\152\153\154\155\156\157\158\159","0000000000000000","ffffffffffffffff",10},
      {"\160\161\162\163\164\165\166\167\168\169\170\171\172\173\174\175","0000000000000000","ffffffffffffffff",11},
      {"\176\177\178\179\180\181\182\183\184\185\186\187\188\189\190\191","0000000000000000","ffffffffffffffff",12},
      {"\192\193\194\195\196\197\198\199\200\201\202\203\204\205\206\207","0000000000000000","ffffffffffffffff",13},
      {"\208\209\210\211\212\213\214\215\216\217\218\219\220\221\222\223","0000000000000000","ffffffffffffffff",14},
      {"\224\225\226\227\228\229\230\231\232\233\234\235\236\237\238\239","0000000000000000","ffffffffffffffff",15},
      {"\240\241\242\243\244\245\246\247\248\249\250\251\252\253\254\255","0000000000000000","ffffffffffffffff",16},
    }
  },
}

local function pullEvent(filter)
  local event = {os.pullEventRaw()}
  if event[1] == "terminate" then
    term.clear()
    term.setCursorPos(1,1)
    error("Program closed")
  elseif event[1] == filter then
    return table.unpack(event)
  end
end

local function promptPrint(str)
  term.setTextColour(data.promptColour)
  print(str)
  term.setTextColour(data.textColour)
end

local function boolX(bool)
  if bool then return "X" else return " " end
end

local tArgs = {...}
local file = tArgs[1]
if not file then error("\nUsage:\n" .. shell.getRunningProgram() .. " <file.skimg>") end
local fileExtension = sUtils.split(fs.getName(file),".")[2]
if fileExtension ~= "skimg" then error("File must be a \".skimg\" file!") end

term.setTextColour(data.textColour)
term.setBackgroundColour(data.bgColour)
term.clear()

-- if file doesn't exist, run through creating the file.
if not fs.exists(tArgs[1]) then
  promptPrint("File not found, do you want to create it?")
  term.setTextColour(data.textColour)
  local accept = sUtils.confirm()
  if accept then 
    local x,y,name
    promptPrint("How wide is the canvas? ")
    x = sUtils.readNumber()
    promptPrint("How tall is the canvas? ")
    y = sUtils.readNumber()
    promptPrint("Who is the creator of the image? ")
    name = read()
    x = x or 10
    y = y or 10
    name = name or "nil"
    local canvas = sUtils.asset.skimg.generateDefaultSkimg(x,y,name,false)
    sUtils.encfwrite(file,canvas)
    term.clear()
  end
end

local image = sUtils.asset.load(file)
local imageAttributes = image.attributes
local canvasX,canvasY = imageAttributes.width,imageAttributes.height
local ram = {
  event = {},
  activeChar = { -- this is the character in the canvas
    x = 1,
    y = 1,
  },
  char = { -- this is the character in the chars window
    char = "\1"
  },
  col = {
    fg = "0",
    bg = "f",
  },
  menus = {
    active ={
      drag = false,
      lock = false,
    },
    open = {
      file = false,
      canvas = false,
    }
  },
  running = true,
}

local function getCharacterInfo(x,y)
  x = x or 1
  y = y or 1
  -- make sure that x/y is in canvas
  if x > canvasX then x = canvasX end
  if y > canvasY then y = canvasY end
  
  local char = image.data[y][1]:sub(x,x)
  local fg = image.data[y][2]:sub(x,x)
  local bg = image.data[y][3]:sub(x,x)
  return {char,fg,bg}
end

local function drawInfoFields()
  local x = canvasX+14
  term.setCursorPos(x,2)
  term.blit("Selected Cell","4444444444444","fffffffffffff")
  term.setCursorPos(x,3)
  term.blit("X:","44","ff")
  term.setCursorPos(x,4)
  term.blit("Y:","44","ff")
  term.setCursorPos(x,5)
  term.blit("Char:","44444","fffff")
  term.setCursorPos(x,6)
  term.blit("FG:","444","fff")
  term.setCursorPos(x,7)
  term.blit("BG:","444","fff")
end

local function drawInfoData(charX,y,char,fg,bg)
  local x = canvasX+14
  term.setCursorPos(x+3,3)
  local strX = sUtils.cut(tostring(charX),3)
  term.blit(strX,("0"):rep(strX:len()),("f"):rep(strX:len()))
  term.setCursorPos(x+3,4)
  local strY = sUtils.cut(tostring(y),3)
  term.blit(strY,("0"):rep(strY:len()),("f"):rep(strY:len()))
  term.setCursorPos(x+6,5)
  term.blit(char,fg,bg)
  term.setCursorPos(x+5,6)
  local wordFG = data.blitToWord[fg]
  term.blit(sUtils.cut(wordFG,10),"0000000000","ffffffffff")
  term.setCursorPos(x+5,7)
  local wordBG = data.blitToWord[bg]
  term.blit(sUtils.cut(wordBG,10),"0000000000","ffffffffff")
end

local wins = {}
wins.borderWin = window.create(term.current(),1,2,canvasX+2,canvasY+2)
wins.canvasWin = window.create(wins.borderWin,2,2,canvasX,canvasY)
wins.colourWin = window.create(term.current(),canvasX+3,2,11,6)
wins.charWin = window.create(term.current(),canvasX+2,8,18,18)
wins.debugWin = window.create(term.current(),50,1,120,50,false)
wins.resizeWin = window.create(term.current(),1,canvasY+10,18,6,false)

local function debugWrite(str)
  wins.debugWin.write(str)
  local x,y = wins.debugWin.getCursorPos()
  if x >= 40 then wins.debugWin.clear() wins.debugWin.clear() wins.debugWin.setCursorPos(1,1) end
  wins.debugWin.setCursorPos(1,y+1)
end

-- draw the various borders around the windows
paintutils.drawBox(1,1,canvasX+2,canvasY+2,colours.white,wins.borderWin)
paintutils.drawBox(1,1,18,18,colours.white,wins.charWin)

sUtils.asset.drawSkimg(image,1,1,wins.canvasWin)
sUtils.asset.drawSkimg(assets.colours,1,1,wins.colourWin)
sUtils.asset.drawSkimg(assets.characters,2,2,wins.charWin)
-- Draw the file menu buttons
sUtils.asset.drawBlit(assets.fileMenu,canvasX+20,8)

drawInfoFields()

local function getPixel(tbl,x,y)
  local charString = tbl[y][1]
  local fgString = tbl[y][2]
  local bgString = tbl[y][3]
  local char = charString:sub(x,x)
  local fg = fgString:sub(x,x)
  local bg = bgString:sub(x,x)
  return {char,fg,bg} 
end

local function getPixelSingle(tbl,x,y)
  local charString = tbl[y]
  local char = charString:sub(x,x)
  return char
end

local function setPixel(x,y,char,fg,bg)
  char = char or ram.char.char
  fg = fg or ram.col.fg
  bg = bg or ram.col.bg
  local blitLine = image.data[y]
  local charLine = sUtils.splice(blitLine[1],x-1,char,true)
  local fgLine = sUtils.splice(blitLine[2],x-1,fg,true)
  local bgLine = sUtils.splice(blitLine[3],x-1,bg,true)
  wins.canvasWin.setCursorPos(1,y)
  term.blit(charLine,fgLine,bgLine)
  image.data[y] = {charLine,fgLine,bgLine,y}
end

local function drawChars(fg,bg)
  local chars = assets.characters.data
  for i=1,#chars do
    chars[i][2] = fg:rep(16)
    chars[i][3] = bg:rep(16)
  end
  sUtils.asset.drawBlit(chars,2,2,wins.charWin)
end

local function setColour(arg)
  local x,y
  local event = ram.event
  if arg then
    x = event[3] - canvasX-3
    y = event[4] - 2
    debugWrite(tostring(x) .. " " .. tostring(y))
    local char = getPixelSingle(assets.col,x,y)
    ram.col.fg = char
  end
  if not arg then
    x = event[3] - canvasX-8
    y = event[4] - 2
    debugWrite(tostring(x) .. " " .. tostring(y))
    local char = getPixelSingle(assets.col,x,y)
    ram.col.bg = char
  end
  drawChars(ram.col.fg,ram.col.bg)
end

local function captureCanvas()
  local x,y = wins.canvasWin.getSize()
  local screenshot = {}
  for i=1,y do
    screenshot[i] = {wins.canvasWin.getLine(i)}
    screenshot[i][4] = i
  end
  return screenshot
end

local function save(location)
  local path = location or tArgs[1]
  local skimg = {
    attributes = imageAttributes,
    data = image.data,
  }
  --sUtils.encfwrite(path,skimg)
  sUtils.encfwrite(path,skimg)
end

local function changePixel()
  ram.activeChar.x = ram.event[3]
  ram.activeChar.y = ram.event[4]-2
  local x,y = ram.activeChar.x,ram.activeChar.y
  if ram.event[2] == 1 then
    ram.activeChar.info = getCharacterInfo(ram.activeChar.x,ram.activeChar.y)
    drawInfoData(ram.activeChar.x,ram.activeChar.y,ram.activeChar.info[1],ram.activeChar.info[2],ram.activeChar.info[3])
    term.setCursorPos(ram.event[3],ram.event[4])
    term.setCursorBlink(true)
    setPixel(x,y)
  elseif ram.event[2] == 2 then
    ram.activeChar.info = getCharacterInfo(ram.activeChar.x-1,ram.activeChar.y)
    drawInfoData(ram.activeChar.x-1,ram.activeChar.y,ram.activeChar.info[1],ram.activeChar.info[2],ram.activeChar.info[3])
    term.setCursorPos(ram.event[3],ram.event[4])
    term.setCursorBlink(true)
  end
end

local function setChar()
  local x,y = ram.event[3]-canvasX-2,ram.event[4]-8
  ram.char.char = getPixel(assets.characters.data,x,y)[1]
  debugWrite(ram.char)
end

local buttonIDs
local function resizeCanvas()
  -- Pop up a window over canvas/border win, also close file menu.
  wins.resizeWin.setVisible(true)
  sUtils.asset.drawBlit(assets.resize,1,1,wins.resizeWin)
  wins.resizeWin.setCursorPos(1,2)
  local accept = sUtils.confirm()
  if not accept then
    term.clear()
    wins.resizeWin.setVisible(false)
    wins.borderWin.redraw()
    wins.charWin.redraw()
    wins.canvasWin.redraw()
    wins.colourWin.redraw()
    drawInfoFields()
    sUtils.asset.drawBlit(assets.fileMenu,canvasX+20,8)
    paintutils.drawBox(1,1,canvasX+2,canvasY+2,colours.white,wins.borderWin)
    paintutils.drawBox(1,1,18,18,colours.white,wins.charWin)
    sUtils.asset.drawSkimg(image,1,1,wins.canvasWin)
    sUtils.asset.drawSkimg(assets.colours,1,1,wins.colourWin)
    sUtils.asset.drawSkimg(assets.characters,2,2,wins.charWin)
    return
  end
  wins.resizeWin.setCursorPos(1,4)
  local x = sUtils.readNumber()
  wins.resizeWin.setCursorPos(1,6)
  local y = sUtils.readNumber()

  -- If new canvas is smaller, delete some data
  if x < canvasX then
    for i=1,#image.data do
      image.data[i][1] = sUtils.cut(image.data[i][1],x)
      image.data[i][2] = sUtils.cut(image.data[i][2],x)
      image.data[i][3] = sUtils.cut(image.data[i][3],x)
    end
  end
  -- If new canvas is bigger, repeat some data
  if x > canvasX then
    for i=1,#image.data do
      local length = image.data[i][1]:len()
      local char = image.data[i][1]:sub(length,length)
      local fg = image.data[i][2]:sub(length,length)
      local bg = image.data[i][3]:sub(length,length)
      image.data[i][1] = sUtils.cut(image.data[i][1],x,char)
      image.data[i][2] = sUtils.cut(image.data[i][2],x,fg)
      image.data[i][3] = sUtils.cut(image.data[i][3],x,bg)
    end
  end
  -- If new canvas is shorter, delete some data
  if y < canvasY then
    for i=y+1,#image.data do
      image.data[i] = nil
    end
  end
  -- If new canvas is taller, repeat some data
  if y > canvasY then
    local repeatLine = image.data[#image.data]
    for i=canvasY+1,y do
      image.data[i] = repeatLine
      image.data[i][4] = i
    end
  end
  imageAttributes.width = x
  imageAttributes.height = y
  canvasX = imageAttributes.width
  canvasY = imageAttributes.height

  local x,y = wins.borderWin.getPosition()
  wins.borderWin.reposition(x,y,canvasX+2,canvasY+2)
  local x,y = wins.canvasWin.getPosition()
  wins.canvasWin.reposition(x,y,canvasX,canvasY)
  wins.colourWin.reposition(canvasX+3,2,11,6)
  wins.charWin.reposition(canvasX+2,8,18,18)

  -- Redraw ***ALL*** the stuffs. this is painful. why do i exist. this is a nightmare nightmare nightmare nightmare nightmare nightmare nightmare nightmare 
  term.clear()
  wins.resizeWin.setVisible(false)
  wins.borderWin.redraw()
  wins.charWin.redraw()
  wins.canvasWin.redraw()
  wins.colourWin.redraw()
  drawInfoFields()
  sUtils.asset.drawBlit(assets.fileMenu,canvasX+20,8)
  paintutils.drawBox(1,1,canvasX+2,canvasY+2,colours.white,wins.borderWin)
  paintutils.drawBox(1,1,18,18,colours.white,wins.charWin)

  sUtils.asset.drawSkimg(image,1,1,wins.canvasWin)
  sUtils.asset.drawSkimg(assets.colours,1,1,wins.colourWin)
  sUtils.asset.drawSkimg(assets.characters,2,2,wins.charWin)

  -- Now the really complicated bit, reassigning the buttons... nightmare nightmare nightmare nightmare nightmare nightmare nightmare nightmare nightmare nightmare nightmare nightmare
  button.edit(buttonIDs.canvas,nil,nil,canvasX,canvasY)
  button.edit(buttonIDs.characters,canvasX+3)
  button.edit(buttonIDs.colFG,canvasX+4)
  button.edit(buttonIDs.colBG,canvasX+9)
  button.edit(buttonIDs.redraw,canvasX+20)
  button.edit(buttonIDs.resize,canvasX+20)
  button.edit(buttonIDs.save,canvasX+20)
  button.edit(buttonIDs.exit,canvasX+20) 
  return
end

buttonIDs = {
  canvas = button.newButton(2,3,canvasX,canvasY,changePixel),
  characters = button.newButton(canvasX+3,9,16,16,setChar),
  colFG = button.newButton(canvasX+4,3,4,4,function() setColour(true) end),
  colBG = button.newButton(canvasX+9,3,4,4,function() setColour(false) end),
  redraw = button.newButton(20,8,7,1,function() paintutils.drawBox(1,1,canvasX+2,canvasY+2,colours.white,wins.borderWin)sUtils.asset.drawSkimg(image,1,1,wins.canvasWin) end),
  resize = button.newButton(canvasX+20,9,7,1,function() resizeCanvas() end),
  save = button.newButton(  canvasX+20,10,7,1,function() save() end),
  exit = button.newButton(  canvasX+20,11,7,1,function() ram.running = false end),
}

term.setCursorPos(1,canvasY+4)

local function handleEvent(event)
  ram.event = event
  --debugWrite(textutils.serialize(event))
  if event[1] == "mouse_click" then
    button.executeButtons(event)
  elseif event[1] == "mouse_drag" then
    button.executeButtons(event,true)
  end
end

local function main()
  while ram.running do
    handleEvent({os.pullEvent()})
  end
  term.clear()
  term.setCursorPos(1,1)
  term.setBackgroundColour(colours.black)
  term.setTextColour(colours.white)
  term.write("Closed.")
  term.setCursorPos(1,2)
end

parallel.waitForAny(main)--,handleMenus)