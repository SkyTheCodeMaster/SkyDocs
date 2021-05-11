--- sUtils is a utility api with a large amount of functions for various purposes
-- @module[kind=misc] sUtils

local expect = require("cc.expect").expect
local nft = require("cc.image.nft")

--- General functions
-- Random, useful functions
-- @section randomfunctions

--- Loop through a table, and check if it contains the value specified
-- @tparam table Table to loop through.
-- @tparam any value Value to look for in the table.
-- @treturn boolean True if the table contains the value.
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

--- Loop through a table, and check if it contains the value specified
-- @tparam table Table to loop through.
-- @tparam any value Value to look for in the table.
-- @treturn boolean True if the table contains the value.
local function keyContains(t, value)
  expect(1,t,"table")
  expect(1,value,"any")
  for k,v in pairs(t) do
    if k == value or v == value then
      return true
    end
  end
  return false
end

--- Grab a file from the internet and save it in the file path.
-- @tparam string file Path to the file to save in.
-- @tparam string url URL to get the content from.
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

--- Split a string by it's separator.
-- @tparam string inputstr String to split.
-- @tparam string sep Separator to split the string by.
-- @treturn table Table containing the split string.
local function split(inputstr, sep)
  expect(1,inputstr,"string")
  expect(1,sep,"string")
  sep = sep or "%s"
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
          table.insert(t, str)
  end
  return t
end

--- Count the number of lines in the file.
-- @tparam string file File to count the lines of.
-- @treturn number lines Amount of lines in the file.
local function countLines(path)
  expect(1,path,"string")
  local lines = 0 
  for _ in io.lines(path) do lines = lines + 1 end 
  return lines
end

--- Returns a boolean on if the number is odd or not.
-- @tparam number num Number to check the oddness.
-- @treturn boolean odd True if the number is odd.
local function isOdd(num)
  return num % 2 == 0
end

--- Recursively get the size of a folder.
-- @tparam string path Path to the folder or file.
-- @treturn number size Size of the folder or file.
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

--- Cut or pad a string to length.
-- @tparam string str String to cut or pad.
-- @tparam number len Length to cut or pad to.
-- @tparam[opt] string pad Padding to extend the string if necessary. Defaults to " ".
-- @treturn string Cut or padded string.
local function cut(str,len,pad)
  pad = pad or " "
  return str:sub(1,len) .. pad:rep(len - #str)
end

--- Splice and insert a character into a string.
-- @tparam string str String to be spliced.
-- @tparam number pos Where to insert the character.
-- @tparam string char Character to insert.
-- @tparam[opt] boolean replace Replace the character, or just insert a new one. Defaults to false.
-- @treturn string The spliced string.
local function splice(str,pos,char,replace)
  local len = str:len()
  local one = str:sub(1,pos-1)
  local two = str:sub(pos,len)
  local final
  if not replace then
    final = one .. char .. two
    return final
  else
    local temp = two:sub(2)
    final = one .. char .. temp
    return final
  end
end

--- Generate a random number based on math.random(), and the current time.
-- @treturn number A mostly random number.
local function generateRandom()
  --[[
    This function is not truly random. It uses a combination of math.random() and the current time to return a pseudo random number.
  ]]
  local epoch = math.floor(os.epoch("utc") / 1000) + (3600 * math.random(math.random(math.random(1,234),math.random(1,42345))))
  local t = os.date("!*t",epoch)
  return (t.hour * t.min * t.sec) * (t.hour + t.min + t.sec)
end

--- Roll a dice with a specified modifier, and check if it passes the DC.
-- @tparam number size Number of sides of the dice.
-- @tparam number modifier Bonuses of the roll.
-- @tparam number dc DC to check the roll against.
-- @treturn boolean If the roll passes the DC.
-- @treturn number The final roll.
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

--- Get the current time with an offset from UTC.
-- @tparam number offset Offset from UTC.
-- @treturn table Table containing the time.
local function getTime(offset)
  expect(1,offset,"number","nil")
  offset = offset or 0
  local epoch = math.floor(os.epoch("utc") / 1000) + (3600 * offset)
  local t = os.date("!*t",epoch)
  return t
end

--- file oriented functions
-- @section file

--- Read the contents of a file.
-- @tparam string file Path to the file.
-- @treturn string Contents of the file.
local function fread(file)
  expect(1,file,"string")
  local f = fs.open(file,"r")
  local contents = f.readAll()
  f.close()
  return contents
end

--- Write contents to a file.
-- @tparam string file Path to the file.
-- @tparam string Contents to write to the file.
local function fwrite(file,contents)
  expect(1,file,"string")
  expect(2,contents,"string")
  local f = fs.open(file,"w")
  f.write(contents)
  f.close()
end

--- Serialize a lua object, and write it to a file.
-- @tparam string path Path to the file.
-- @param object Any serializable lua object.
local function encfwrite(file,object)
  local obj = textutils.serialize(object)
  fwrite(file,obj)
end

--- encfread reads a file, and unserializes the lua object.
-- @tparam string Path to file.
-- @return Any lua object from the file.
local function encfread(file)
  local contents = fread(file)
  return textutils.unserialize(contents)
end

--- hread reads from a url
-- @tparam string url URL to read from.
-- @treturn string|nil Contents of the page, if any.
-- @treturn nil|any Failing response, if any.
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

--- Poke a file, creating it if it doesn't exist.
-- @tparam string Path to the file.
local function poke(file)
  fs.open(file,"a").close()
end

--- webquire is a `require` but for URLs
-- @tparam string url URL to download the module from.
-- @treturn The loaded module, like what `require` would return.
local function webquire(url)
  local content,err = hread(url)
  if not content then error("webquire: " .. err) end
  local lib = load(content,"=webquire_package","t",_ENV)() -- load the content, name it as a `=webquire_package`, make it only load text lua, not bytecode, pass `_ENV` to it.
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

--- Read user input, compare it to a table of agree phrases.
-- @treturn boolean Whether or not the user agreed to the prompt.
local function confirm(replaceChar,history,completeFn,default)
  local answer = read(replaceChar,history,completeFn,default)
  return not not agreePhrases[answer:upper()]
end

--- Read user input, return `tonumber()` of it.
-- @treturn number Number the user input.
local function readNumber(replaceChar,history,completeFn,default)
  local answer = read(replaceChar,history,completeFn,default)
  return tonumber(answer)
end

--- Caching section
-- @section cache

--- Cache where the files are stored, it's key/value with `cache[path] = contents`.
local cache = {}

--- Load a file, checks if it's in the cache, if so, return that, if not, return the file and put it in cache.
-- @tparam string path Path to the file.
-- @treturn string Contents of the file
local function cacheLoad(path)
  if cache[path] then
    return cache[path]
  else
    local contents = fread(path)
    cache[path] = contents
    return contents
  end
end

--- Reload a file in the cache, overwriting it with the new contents.
-- @tparam string path Path to the file to reload.
-- @treturn string The old contents of the file.
local function reload(path)
  local contents = fread(path)
  local old = cache[path]
  cache[path] = contents
  return old
end

--- asset loading routines
-- @section assets

--- Load an image file.
-- @tparam string path Path to the file, supported types are ".skimg", ".skgrp", ".blit", ".nfp", and ".nft".
-- @treturn table The image file, to be fed into a drawing routine.
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
--- Draw the given `skgrp` file.
-- @tparam table Table of instructions to draw.
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
-- @tparam table skimg The skimg image to draw.
-- @tparam[opt] number x X coordinate, defaults to 1.
-- @tparam[opt] number y Y coordinate, defaults to 1.
-- @tparam[opt] table output Output terminal, defaults to `term.current()`
local function drawSkimg(tbl,x,y,tOutput)
  expect(1,tbl,"table")
  expect(2,x,"number","nil")
  expect(3,y,"number","nil")
  expect(4,tOutput,"table","nil") -- tOutput is a term-like object. MUST SUPPORT BLIT!!!
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
-- @tparam table blit Blit image to draw.
-- @tparam[opt] number x X coordinate of the image, defaults to 1.
-- @tparam[opt] number y X coordinate of the image, defaults to 1.
-- @tparam[opt] table output Output terminal, defaults to `term.current()`.
local function drawBlit(tbl,x,y,tOutput)
  expect(1,tbl,"table")
  expect(2,x,"number","nil")
  expect(3,y,"number","nil")
  expect(4,tOutput,"table","nil")
  x = x or 1
  y = y or 1
  tOutput = tOutput or term.current()
  for i=1,#tbl do
    local blitLine = tbl[i]
    tOutput.setCursorPos(x,y+i-1)
    tOutput.blit(blitLine[1],blitLine[2],blitLine[3])
  end
end

--- Generates a `skimg` image with the provided width, and height.
-- @tparam number width Width of the image.
-- @tparam number height Height of the image.
-- @tparam string creator Creator of the image.
-- @tparam boolean locked Whether or not the file is locked from editing.
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
--- Get the attributes of a `.skimg` file or image table.
-- @tparam string|table image Path to a file, or a `.skimg` table.
-- @treturn table Attributes of the image.
local function getAttributes(fileTable)
  expect(1,fileTable,"string","table")
  local tbl = {}
  if fs.exists(fileTable) then
    -- its a file, read the contents and put them into the internal table
    tbl = load(fileTable)
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
  --- Asset functions.
  asset = {
    load = load,
    drawSkgrp = drawSkgrp,
    drawSkimg = drawSkimg,
    drawBlit = drawBlit,
    --- Skimg asset functions.
    skimg = {
      getAttributes = getAttributes,
      generateDefaultSkimg = generateDefaultSkimg,
    },
  },
  --- Cache functions, stores files in a cache for faster access. (Read only)
  cache = {
    cacheData = cache,
    cacheLoad = cacheLoad,
    reload = reload,
  },
  numericallyContains = numericallyContains,
  keyContains = keyContains,
  getFile = getFile,
  isOdd = isOdd,
  split = split,
  cut = cut,
  splice = splice,
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