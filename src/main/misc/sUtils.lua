--- sUtils is a utility api with a large amount of functions for various purposes
-- @module[kind=misc] sUtils

local expect = require("cc.expect").expect
local nft = require("cc.image.nft")

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
    error("Failed too many times. Stopping.", 2)
  end
 
  local h, err = http.get(sNetAddress)
  if h then
    local fh, err2 = io.open(sFilename, 'w')
    if fh then
      fh:write(h:readAll()):close()
      h.close()
    else
      h.close()
      printError("Failed to write file: " .. err2,2)
      getFile(sFilename, sNetAddress, nFails + 1)
    end
  else
    printError("Failed to connect: " .. err,2)
    getFile(sFilename, sNetAddress, nFails + 1)
  end
end

--- Split a string by it's separator.
-- @tparam string inputstr String to split.
-- @tparam string sep Separator to split the string by.
-- @treturn table Table containing the split string.
local function split(inputstr, sep)
  expect(1,inputstr,"string")
  expect(1,sep,"string","nil")
  sep = sep or ","
  local t={}
  for str in inputstr:gmatch("([^"..sep.."]+)") do
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
-- @tparam[opt=false] boolean ignoreRom Whether or not to discard all entries of `rom`.
-- @treturn number size Size of the folder or file.
local function getSize(path,ignoreRom)
  expect(1,path,"string")
  expect(2,ignoreRom,"boolean","nil")
  local size = 0
  local files = fs.list(path)
  for _,v in pairs(files) do
    if not ignoreRom or v ~= "rom" then
      if fs.isDir(fs.combine(path, v)) then
        size = size + getSize(fs.combine(path, v))
      else
        size = size + fs.getSize(fs.combine(path, v))
      end
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
  local epoch = math.floor(os.epoch("utc") / 1000) + 3600 * math.random(math.random(math.random(1,234),math.random(1,42345)))
  local t = os.date("!*t",epoch)
  return t.hour * t.min * t.sec * (t.hour + t.min + t.sec)
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
-- @tparam[opt] number offset Offset from UTC.
-- @treturn table Table containing the time.
local function getTime(offset)
  expect(1,offset,"number","nil")
  offset = offset or 0
  local epoch = math.floor(os.epoch("utc") / 1000) + 3600 * offset
  local t = os.date("!*t",epoch)
  return t
end

--- Get the current time in a table of strings prepended with `0` if they're single digit.
-- @tparam[opt] number offset Offset from UTC.
-- @treturn table Table containing the time.
local function getZeroTime(offset)
  expect(1,offset,"number","nil")
  local t = getTime(offset)
  local time = {
    sec = t.sec,
    min = t.min,
    hour = t.hour,
    day = t.day,
    month = t.month,
    year = t.year,
  }
  for k,v in pairs(time) do
    local str = tostring(v)
    if str:len() == 1 then
      str = "0" .. str
    end
    time[k] = str
  end
  return time
end

--- Read the contents of a file.
-- @tparam string file Path to the file.
-- @treturn string|nil Contents of the file, or nil if the file doesn't exist.
local function fread(file)
  expect(1,file,"string")
  local f = fs.open(file,"r")
  if not f then return nil end -- File does not exist
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

--- Webquire is a `require` but for URLs
-- @tparam string url URL to download the module from.
-- @return The loaded module, like what `require` would return.
local function webquire(url)
  local content,err = hread(url)
  if not content then error("webquire: " .. err,2) end
  local lib = load(content,"=webquire_package","t",_ENV)() -- load the content, name it as a `=webquire_package`, make it only load text lua, not bytecode, pass `_ENV` to it.
  return lib
end

--- savequire uses @{sUtils.webquire|webquire} but will also save the file and use that if it's found.
-- @tparam string url URL to download the module from.
-- @return The loaded module, like what `require` would return.
local function savequire(url)
  local splitURL = split(url,"/") -- Split url to get the individual pieces, used to grab the filename.
  local name = splitURL[#splitURL]
  local package
  if not fs.exists(fs.combine("savequire",name)) then -- We dont have the package locally, download it from the web
    local content,err = hread(url)
    if not content then error("savequire: " .. err,2) end
    fwrite(fs.combine("savequire",name),content.readAll())
    package = require(fs.combine("savequire",name))
  else
    package = require(fs.combine("savequire",name))
  end
  return package
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

--- Read user input, compare it to a table of agree phrases.
-- @treturn boolean Whether or not the user agreed to the prompt.
local function confirm(replaceChar,history,completeFn,default)
  local answer = read(replaceChar,history,completeFn,default)
  return not not agreePhrases[answer:upper()]
end

--- Read user input, return `tonumber()` of it.
-- @treturn number Number the user input.
local function readNumber(...)
  local answer
  repeat 
   answer = tonumber(read(...))
  until answer
  return tonumber(answer)
end

--- "Canadianify" a text.
-- @tparam string text Text to candianify.
-- @treturn string Canadian text.
local function canadianify(text)
  return "sorry " .. text .. " eh"
end

--- "Americanify" a text.
-- @tparam string text Text to americanify.
-- @tparam[opt=1] number case Which type of modification to use. 1 = "I'm walkin here!" .. text .. " Forget about it!", 2 = "Oil? " .. text .. " The First Amendment."
-- @treturn string American text.
local function americanify(text,case)
  case = case or 1
  if case == 1 then
    return "I'm walkin here! " .. text .. " Forget about it!"
  elseif case == 2 then
    return "Oil? " .. text .. " The First Amendment."
  end
end

--- Check if a value is already in a table, if not, insert it.
-- @tparam table tbl Table to insert to.
-- @param value Value to insert.
-- @treturn table Modified table.
local function insert(tbl,value)
  local present = false
  for _,v in pairs(tbl) do
    if v == value then
      present = true
    end
  end
  if not present then
    table.insert(tbl,value)
  end
  return tbl
end

--- Remove all values from a table. 
-- @tparam table tbl Table to remove from.
-- @param value Value to remove.
-- @treturn table Modified table.
local function remove(tbl,value)
  for k,v in pairs(tbl) do
    if v == value then
      if type(k) == "number" then -- This is a numerically indiced table, we need to shift the other elements.
        table.remove(tbl,k)
      else -- key/value, just set to nil.
        tbl[k] = nil
      end
    end
  end
  return tbl
end

--- Shallow copy a table, not recursive so doesn't copy table elements.
-- @tparam table tbl Table to copy.
-- @treturn table Copied table. 
local function shallowCopy(tbl)
  local newTbl = {}
  for k,v in pairs(tbl) do
    newTbl[k] = v
  end
  return newTbl
end

--- Deep copy a table, recurses to nested tables.
-- @tparam table tbl Table to copy. 
-- @treturn table Copied table. 
local function deepCopy(tbl)
  local newTbl = {}
  for k,v in pairs(tbl) do
    if type(v) == "table" then
      newTbl[k] = deepCopy(v)
    else
      newTbl[k] = v
    end
  end
  return newTbl
end

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

--- Load an image file.
-- @tparam string path Path to the file, supported types are ".skimg", ".skgrp", ".blit", ".nfp", and ".nft".
-- @tparam string override Type to load file as, overriding the file type.
-- @treturn table The image file, to be fed into a drawing routine.
local function load(file,override)
  expect(1,file,"string")
  expect(2,override,"string","nil")
  if not fs.exists(file) then
    error("file does not exist",2)
  end
  local fileName = fs.getName(file)
  local fileType = override or split(fileName,".")[2]
  local mt = {
    __index = function(self,i)
      if i == "format" then
        return fileType
      end
      return rawget(self,i)
    end,
  }
  local img = {}
  -- skimg loader
  if fileType == "skimg" then
    img = encfread(file)
  -- skgrp loader (old & outdated)
  elseif fileType == "skgrp" then
    for x in io.lines(file) do
      table.insert(img,x)
    end
  -- blit loader, similar to `.skimg`
  elseif fileType == "blit" then
    img = encfread(file)
  -- nfp loader, for paintutils
  elseif fileType == "nfp" then
    img = paintutils.loadImage(file)
  -- nft loader, "Nitrogen Fingers Text"
  elseif fileType == "nft" then
    img = nft.load(file)
  end
  return setmetatable(img,mt)
end

--[[- Draw an image produced by @{load}.
@param image Image to draw.
@tparam {format? = string, x? = number, y? = number} opts Options for picture drawing.
 - `format`: Format to draw image as, if unpassed will try to figure out the image type.
 - `x`: X position to draw image at. Defaults to 1.
 - `y`: Y position to draw image at. Defaults to 1.
@tparam[opt] table tOutput Terminal to draw to. Has different requirements based on image type. Defaults to `term.current()`
]] 
local function draw(image,options,tOutput)
  expect(1,image,"string","table")
  expect(2,options,"table","nil")
  expect(3,tOutput,"table","nil")
  tOutput = tOutput or term.current()
  local opts = options or {}
  local x = opts["x"] or 1
  local y = opts["y"] or 1
  local format,sType,sDelay
  -- Default the table!
  if not opts["format"] or not image["format"] then
    -- Now we need to figure it out.
    if type(image) == "table" then -- This is a skimg or skgrp.
      if image["attributes"] and image["data"] then -- This is a skimg. Lets figure out it's type.
        if image["attributes"]["type"] then
          sType = image["attributes"]["type"]
          format = "skimg"
        else
          sType = 1
          format = "skimg"
        end
        if sType == 2 then -- ok, get it's speed. (This is stored inside of attributes, and defaults to 0.05)
          sDelay = image["attributes"]["speed"] or 0.05
        end
      else -- Check if it's a blit, nft or skgrp.
        if type(image[1]) == "table" then
          -- It's a blit or nft.
          if image[1]["text"] then
            format = "nft"
          else
            format = "blit"
          end
        elseif type(image[1]) == "string" then
          -- It's a skgrp.
          format = "skgrp"
        end
      end
    elseif type(image) == "string" then
      -- It's an NFP.
      format = "nfp"
    end
  else
    format = opts["format"] or image["format"]
  end
  if format == "skimg" and sType == 1 then
    -- Type one skimg. Easy to draw.
    -- make sure tOutput has blit and setCursorPos
    if not tOutput.setCursorPos or not tOutput.blit then
      error("tOutput is incompatible!",2)
    end
    for i,v in ipairs(image.data) do
      tOutput.setCursorPos(x,y+i-1)
      tOutput.blit(v[1],v[2],v[3])
    end
  elseif format == "skimg" and sType == 2 then
    -- Basically calls the type 1 parser on each frame, with a `sleep` in between.
    -- make sure tOutput has blit and setCursorPos
    if not tOutput.setCursorPos or not tOutput.blit then
      error("tOutput is incompatible!",2)
    end
    local frames = image.data
    for _,v in ipairs(frames) do
      local frame = v
      for i,l in ipairs(frame) do
        tOutput.setCursorPos(x,y+i-1)
        tOutput.blit(l[1],l[2],l[3])
      end
      sleep(sDelay)
    end
  elseif format == "blit" then
    -- Relatively the same as skimg type 1.
    -- make sure tOutput has blit and setCursorPos
    if not tOutput.setCursorPos or not tOutput.blit then
      error("tOutput is incompatible!",2)
    end
    for i,v in ipairs(image) do
      tOutput.setCursorPos(x,y+i-1)
      tOutput.blit(v[1],v[2],v[3])
    end
  elseif format == "nft" then
    nft.draw(image,x,y,tOutput)
  elseif format == "nfp" then
    paintutils.drawImage(image,x,y) -- SkyOS no longer uses modded paintutils, so drawImage will exist.
  elseif format == "skgrp" then
    for i=1,#image do
      local grpTable = split(image[i],",")
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
end

-- THIS FILETYPE IS DEPRECATED, DO NOT USE. (not documented) 
--- Draw the given `skgrp` file.
-- @tparam table Table of instructions to draw.
-- @deprecated skgrp is not maintained, use @{load}, and @{draw}, or @{drawSkimg}
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
    error("table is not valid .skimg",2)
  end
  -- make sure tOutput has blit and setCursorPos
  if not tOutput.setCursorPos or not tOutput.blit then
    error("tOutput is incompatible!",2)
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
  local tbl
  if fs.exists(fileTable) then
    -- its a file, read the contents and put them into the internal table
    tbl = load(fileTable)
  else
    -- it's not a file, take input and put it into the internal table
    tbl = fileTable
  end
  if tbl.attributes then
    return tbl.attributes
  else
    return nil,"not found"
  end
end

return {
  --- Asset functions.
  asset = {
    load = load,
    draw = draw,
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
  getZeroTime = getZeroTime,
  confirm = confirm,
  readNumber = readNumber,
  poke = poke,
  encfwrite = encfwrite,
  encfread = encfread,
  webquire = webquire,
  savequire = savequire,
  canadianify = canadianify,
  americanify = americanify,
  insert = insert,
  remove = remove,
  shallowCopy = shallowCopy,
  deepCopy = deepCopy,
}
