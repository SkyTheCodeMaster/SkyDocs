--- sUtils is a utility api with a large amount of functions for various purposes
-- https://gist.github.com/SkyTheCodeMaster/63d05e3cb5173eda7f4a6755a8a5c962
-- @module[kind=misc] sUtils

local expect = require("cc.expect").expect
local nft = require("cc.image.nft")

--- General functions
-- Random, useful functions
-- @section randomfunctions

--- numericallyContains will return a boolean if a numerically indiced table contains a value
-- @tparam table table to search through
-- @tparam any value to look for in the table
-- @treturn boolean if the table contains the value
local function numericallyContains(t, value)
  expect(1,t,"table")
  expect(1,value,"any")
  for i = 1, #t do
    if t[i] == value then
      return true
    end
  end
  return false
end

--- getFile will grab a file from the internet and save it in the provided file
-- @tparam string file name to save the webpage input
-- @tparam string url to get the content from
local function getFile(sFilename, sNetAddress, nFails)
  expect(1,sFilename,"string")
  expect(1,sNetAddress,"string")
  nFails = nFails or 0
  if nFails > 5 then
    error("Failed too many times. Stopping.", -1)
  end
 
  local h, err = http.get(sNetAddress)
  if h then
    local fh, err2 = io.open(sFilename, 'w')
    if fh then
      fh:write(h:readAll()):close()
      h.close()
    else
      h.close()
      printError("Failed to write file: " .. err2)
      getFile(sFilename, sNetAddress, nFails + 1)
    end
  else
    printError("Failed to connect: " .. err)
    getFile(sFilename, sNetAddress, nFails + 1)
  end
end

--- split splits the input string by the separator.
-- @tparam string string to split
-- @tparam string separator to split by. the pattern is "([^" .. sep .. "]+)"
-- @treturn table table of the split string, numerically indiced.
local function split (inputstr, sep)
  expect(1,inputstr,"string")
  expect(1,sep,"string")
  sep = sep or "%s"
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
          table.insert(t, str)
  end
  return t
end

--- countLines will count the amount of lines in the file
-- @tparam string path to the file
-- @treturn number number of lines in the file
local function countLines(path)
  expect(1,path,"string")
  local lines = 0 
  for _ in io.lines(path) do lines = lines + 1 end 
  return lines
end

--- getSize will recursively get the size of a directory
-- @tparam string path to the directory
-- @treturn number size of the directory
local function getSize(path)
  expect(1,path,"string")
  local size = 0
  local files = fs.list(path)
  for i=1,#files do
    if fs.isDir(fs.combine(path, files[i])) then
      size = size + getSize(fs.combine(path, files[i]))
    else
      size = size + fs.getSize(fs.combine(path, files[i]))
    end
  end
  return size
end

--- generateRandom generates a random number based on math.random(), and the current time.
-- @treturn number mostly random number.
local function generateRandom()
  --[[
    This function is not truly random. It uses a combination of math.random() and the current time to return a pseudo random number.
  ]]
  local epoch = math.floor(os.epoch("utc") / 1000) + (3600 * math.random(math.random(math.random(1,234),math.random(1,42345))))
  local t = os.date("!*t",epoch)
  return (t.hour * t.min * t.sec) * (t.hour + t.min + t.sec)
end

--- diceRoll will roll a dice with a modifier, and check if it passes the specified dc
-- @tparam number size of the dice
-- @tparam number modifier of the dice roll
-- @tparam number dc to check against
-- @treturn boolean if the dice roll beats the modifier
-- @treturn number the roll with the modifier
local function diceRoll(size,modifier,dc)
  expect(1,size,"number")
  expect(1,modifier,"number")
  expect(1,dc,"number")
  size = size or 100
  modifier = modifier or 0
  dc = dc or 0

  local roll = math.random(1,size) + modifier
  if roll >= dc then return true,roll end
  return false,roll
end

--- getTime gets the current time with an offset from utc
-- @tparam number offset from utc
-- @treturn table table containing time
local function getTime(offset)
  expect(1,offset,"number")
  local epoch = math.floor(os.epoch("utc") / 1000) + (3600 * offset)
  local t = os.date("!*t",epoch)
  return t
end

--- file oriented functions
-- @section file

--- fread read the contents of a file
-- @tparam string path to file
-- @treturn string contents of file
local function fread(file)
  expect(1,file,"string")
  local f = fs.open(file,"r")
  local contents = f.readAll()
  f.close()
  return contents
end

--- fwrite writes content to a file
-- @tparam string path to file
-- @tparam string contents of file
local function fwrite(file,contents)
  expect(1,file,"string")
  expect(2,contents,"string")
  local f = fs.open(file,"w")
  f.write(contents)
  f.close()
end

--- encfwrite serializes a lua object, and then writes it to a file.
-- @tparam string path to file
-- @tparam any lua object to serialize.
local function encfwrite(file,object)
  local obj = textutils.serialize(object)
  fwrite(file,obj)
end

--- encfread reads a file, and unserializes the lua object.
-- @tparam string path to file
-- @treturn any lua object from the file
local function encfread(file)
  local contents = fread(file)
  return textutils.unserialize(contents)
end

--- hread reads from a url
-- @tparam string url to read from
-- @treturn string|nil contents of the site, nil if unavailable
-- @treturn nil|any failing response, if any
local function hread(url)
  expect(1,url,"string")
  local h,err = http.get(url)
  if not h then
    return nil,err
  end
  local contents = h.readAll()
  h.close()
  return contents,nil
end

--- poke just pokes a file, creating it if it doesn't exist.
-- @tparam string path to file to poke.
local function poke(file)
  fs.open(file,"a").close()
end

--- webquire is a `require` but for URLs
-- @tparam string url to download module from
-- @treturn any module, like what require would return.
local function webquire(url)
  local content,err = hread(url)
  if not content then error("webquire: " .. err) end
  local lib = load(content,"=webquire_package","t",_ENV)()
  return lib
end

local agreePhrases = {
  ["YES"] = true,
  ["OK"] = true,
  ["Y"] = true,
  ["YEAH"] = true,
  ["YEP"] = true,
  ["TRUE"] = true,
  ["YUP"] = true,
  ["YA"] = true,
  ["OKAY"] = true,
  ["YAH"] = true,
  ["SURE"] = true,
  ["ALRIGHT"] = true,
  ["WHATEVER"] = true,
  ["WHYNOT"] = true,
  ["WHY NOT"] = true,
  ["K"] = true,
  ["YEA"] = true,
  ["YE"] = true,
  ["YEE"] = true,
  ["AFFIRMATIVE"] = true,
}

--- user interaction functions
-- @section userinteraction

--- confirm does read() and returns a boolean on whether the user agreed or didn't. The arguments are the same as `_G.read()`
-- @treturn boolean whether or not the user agreed.
local function confirm(replaceChar,history,completeFn,default)
  local answer = read(replaceChar,history,completeFn,default)
  return not not agreePhrases[answer:upper()]
end

--- readNumber does read() and return the `tonumber()` result of it. The arguments are the same as `_G.read()`
-- @treturn number `tonumber()` of the input.
local function readNumber(replaceChar,history,completeFn,default)
  local answer = read(replaceChar,history,completeFn,default)
  return tonumber(answer)
end

--- asset loading routines
-- @section assets

--- load loads a file and prepares it for use by drawing routines
-- @tparam string path to the file, supported types are ".skimg", ".skgrp", ".blit", ".nfp", and ".nft".
-- @treturn table the image file, to be fed into a drawing routine
local function load(file)
  expect(1,file,"string")
  if not fs.exists(file) then
    error("file does not exist")
  end
  local fileName = fs.getName(file)
  local fileType = split(fileName,".")[2]
  -- skimg loader
  if fileType == "skimg" then
    local fileTbl = encfread(file)
    return fileTbl
  end
  -- skgrp loader (old & outdated)
  if fileType == "skgrp" then
    local fileTbl = {}
    for x in io.lines(file) do
      table.insert(fileTbl,x)
    end
    return fileTbl
  end
  -- blit loader, similar to `.skimg`
  if fileType == "blit" then
    local fileTbl = encfread(file)
    return fileTbl
  end
  -- nfp loader, for paintutils
  if fileType == "nfp" then
    local img = paintutils.loadImage(file)
    return img
  end
  -- nft loader, "Nitrogen Fingers Text"
  if fileType == "nft" then
    local img = nft.load(file)
    return img
  end
end

-- THIS FILETYPE IS DEPRECATED, DO NOT USE. (not documented)
local function drawSkgrp(tbl)
  expect(1,tbl,"table")
  for i=1,#tbl do
    local grpTable = split(tbl[i],",")
    local operation = grpTable[1]
    if operation == "P" then
      paintutils.drawPixel(grpTable[2],grpTable[3],tonumber(grpTable[4]))
    elseif operation == "B" then
      paintutils.drawBox(grpTable[2],grpTable[3],grpTable[4],grpTable[5],tonumber(grpTable[6]))
    elseif operation == "F" then
      paintutils.drawFilledBox(grpTable[2],grpTable[3],grpTable[4],grpTable[5],tonumber(grpTable[6]))
    elseif operation == "L" then
      paintutils.drawLine(grpTable[2],grpTable[3],grpTable[4],grpTable[5],tonumber(grpTable[6]))
    elseif operation == "TEXT" then
      paintutils.drawText(grpTable[2],grpTable[3],grpTable[4],grpTable[5],grpTable[6])
    end
  end
end

--- drawSkimg takes a skimg table, and draws it at the specified location
-- @tparam table skimg image
-- @tparam number x coordinate, defaults to 1
-- @tparam number y coordinate, defaults to 1
-- @tparam table output terminal, defaults to `term.current()`
local function drawSkimg(tbl,x,y,tOutput)
  expect(1,tbl,"table")
  expect(2,x,"number")
  expect(3,y,"number")
  expect(4,tOutput,"table") -- tOutput is a term-like object. MUST SUPPORT BLIT!!!
  x = x or 1
  y = y or 1
  tOutput = tOutput or term.current()
  -- make sure it's a valid table with both of the `data` and `attributes` fields.
  if not tbl.attributes or not tbl.data then
    error("table is not valid .skimg")
  end
  -- make sure tOutput has blit and setCursorPos
  if not tOutput.setCursorPos or not tOutput.blit then
    error("tOutput is incompatible!")
  end
  for i=1,#tbl.data do
    local blitLine = tbl.data[i]
    tOutput.setCursorPos(x,y+i-1)
    tOutput.blit(blitLine[1],blitLine[2],blitLine[3])
  end
end

--- drawBlit is like drawSkimg, but for a normal blit table.concat
-- @tparam table blit image
-- @tparam number x coordinate of the image, defaults to 1
-- @tparam number y coordinate of the image, defaults to 1
-- @tparam table output terminal, defaults to `term.current()`
local function drawBlit(tbl,x,y,tOutput)
  expect(1,tbl,"table")
  expect(2,x,"number")
  expect(3,y,"number")
  expect(4,tOutput,"table")
  x = x or 1
  y = y or 1
  tOutput = tOutput or term.current()
  for i=1,#tbl do
    local blitLine = tbl[i]
    tOutput.setCursorPos(x,y+i-1)
    tOutput.blit(blitLine[1],blitLine[2],blitLine[3])
  end
end

--- generateDefaultSkimg takes some arguments, and makes a skimg with white "O"s on a green background.
-- @tparam number width of the image
-- @tparam number height of the image
-- @tparam string creator of the image
-- @tparam boolean whether or not the file is locked from editing
local function generateDefaultSkimg(width,height,creator,locked)
  local defaultfg = "0"
  local defaultbg = "d"
  local defaultchar = "o"
  local stringTable = {
    defaultchar:rep(width),
    defaultfg:rep(width),
    defaultbg:rep(width),
  }
  local datatbl = {}
  for i=1,height do
    local tbl = {stringTable[1],stringTable[2],stringTable[3],i}
    table.insert(datatbl,tbl)
  end

  local tbl = {
    attributes = {
      width = width,
      height = height,
      creator = creator,
      locked = locked,
    },
    data = datatbl,
  }
  return tbl
end

-- This accepts either a file or a table to get attributes from (not working, not documented)
local function getAttributes(fileTable)
  expect(1,fileTable,"string","table")
  local tbl = {}
  if fs.exists(fileTable) then
    -- its a file, read the contents and put them into the internal table
    tbl = textutils.encfread(fileTable)
  else
    -- it's not a file, take input and put it into the internal table
    tbl = fileTable
  end
  if fileTable.attributes then
    return fileTable.attributes
  else
    return nil,"not found"
  end
end

return {
  asset = {
    load = load,
    drawSkgrp = drawSkgrp,
    drawSkimg = drawSkimg,
    drawBlit = drawBlit,
    skimg = {
      getAttributes = getAttributes,
      generateDefaultSkimg = generateDefaultSkimg,
    },
  },
  numericallyContains = numericallyContains,
  getFile = getFile,
  split = split,
  countLines = countLines,
  getSize = getSize,
  generateRandom = generateRandom,
  diceRoll = diceRoll,
  fread = fread,
  fwrite = fwrite,
  hread = hread,
  getTime = getTime,
  confirm = confirm,
  readNumber = readNumber,
  poke = poke,
  encfwrite = encfwrite,
  encfread = encfread,
  webquire = webquire,
}