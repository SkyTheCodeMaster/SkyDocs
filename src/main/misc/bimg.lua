--- An API that draws and manipulates .bimg images.
-- @module[kind=misc] bimg

local expect = require"cc.expect".expect
local field = require"cc.expect".field

local bimg = {}

-- Wooo! OOP!
--- The image object. Contains functions for drawing, and extracting metadata. Created by {@new}.
local image = {} --- @type Image
local mt = {
  __index = image
}

local function splice(str,idx,char)
  return str:sub(1,idx-1) .. char .. str:sub(idx+1,#str)
end

--[[- Draw the image. If this is an animated image in between each frame it will call `sleep`.
  This will not reset cursor position!
  @tparam number x X coordinate to draw the image at.
  @tparam number y Y coordinate to draw the image at.
  @tparam {window?=table,transparency?=boolean} Options that control how the image is drawn.

  - `window`: A window object to draw to. This is so that transparency can be supported. If this is not passed, we will see if `term.current().getLine` exists.
    If it does not, then transparency will not be supported, and will be replaced by black. If a window object is provided then this will draw to that, and call
    `window.setVisible` as appropriate to make the image draw better. Otherwise it will just direct call `term`. It will still call window functions even if
    `transparency` is false.
  - `transparency`: Even if transparency is supported, if this is `false` then it will be replaced by black. Setting this to true can not force transparency
    to work. 
  - `term`: The terminal to draw to, defaults to regular terminal.
]]
function image:draw(x,y,options)
  expect(1,x,"number")
  expect(2,y,"number")
  field(options,"window","table","nil")
  field(options,"transparency","boolean","nil")
  field(options,"term","table","nil")

  local t = options.term or term

  -- Determine if transparency is feasible.
  -- hyper aggressive optimization
  local blit,setCursor,setPaletteColour,tUnpack,pairs,ipairs = t.blit,t.setCursorPos,t.setPaletteColour,table.unpack,pairs,ipairs
  local setVisible = function()end
  local transparency = false
  local getLine
  if not options.transparency == false then
    if options.window then
      transparency = true
      getLine = options.window.getLine
      blit,setCursor = options.window.blit,options.window.setCursorPos
      setVisible = options.window.setVisible or function()end
    else
      if t.current() and t.current().getLine then
        transparency = true
        getLine = t.current().getLine
      end
    end
  end
  -- Set the palette.
  if self.data.palette then
    for k,v in pairs(self.data.palette) do
      setPaletteColour(k,tUnpack(v))
    end
  end

  -- Draw the image. Transparency processing is done on the fly.
  for fI,frame in ipairs(self.data) do
    -- Set the frame palette.
    if frame.palette then
      for k,v in pairs(frame.palette) do
        setPaletteColour(k,tUnpack(v))
      end
    end
    for i,fY in ipairs(frame) do
      local txt = y[1]
      local fg = y[2]
      local bg = y[3]
      if transparency then
        -- Not handle transparency for now.
        setCursor(x,i+y-1)
        blit(
          txt,
          fg:gsub(" ","f"),
          bg:gsub(" ","f")
        )
      else
        setCursor(x,i+y-1)
        blit(
          txt,
          fg:gsub(" ","f"),
          bg:gsub(" ","f")
        )
      end
    end
    if #self.data == 1 or not image.animation then
      sleep(frame.duration or self.data.secondsPerFrame)
    end
  end
end

--- Retrieve the metadata of the image. This returns a table of all of the [metadata](https://github.com/SkyTheCodeMaster/bimg/blob/master/spec.md#metadata) in the bimg format.
--:::info
-- This will also return custom keys, that are not part of the spec.
--:::
-- @treturn table Metadata of the image.
function image:getMetadata()
  local metadata = {}
  for k,v in pairs(self.data) do
    if type(k) == "string" then
      metadata[k] = v
    end
  end
  return metadata
end

--- Set the metadata of the image. This takes a table (Usually one returned by @{image:draw}, but can be custom made), and writes in the keys (Basically a shallow clone) to the image.
-- This will then save the image to a file.
--:::info
-- Custom metadata keys can be added, and it will not complain, but note that other programs might not see these keys, or do anything with them.
--:::
--:::caution
-- This will only write string keys, and will ignore function, table, number, etc. keys.
--:::
-- @tparam table metadata Metdata information.
function image:setMetadata(metadata)
  expect(1,metadata,"table")
  for k,v in pairs(metadata) do
    if type(k) == "string" then
      self.data[k]=v
    end
  end
end

--- This clears the metadata, useful to completely overwrite metadata. It also returns a copy of the removed metadata.
-- @treturn table Old metadata of the image.
function image:clearMetadata()
  local old = {}
  for k,v in pairs(self.data) do
    if type(k) ~= "number" then
      old[k]=v
      self.data[k] = nil
    end
  end
  return old
end

--- Set a pixel at a specific point.
-- @tparam[1] number x X coordinate of the pixel.
-- @tparam[1] number y Y coordinate of the pixel.
-- @tparam[1] string char Character to place.
-- @tparam[1] string|number fg Foreground colour. Accepts either a blit colour or `colours` colour.
-- @tparam[1] string|number bg Background colour. Accepts either a blit colour or `colours` colour.
-- @tparam[1] number frame Frame to set, defaults to 1.
-- @tparam[2] number x X coordinate of the pixel.
-- @tparam[2] number y Y coordinate of the pixel.
-- @tparam[2] {string,string|number,string|number,number} Table describing a character. This follows the same parameters as before.
function image:setPixel(x,y,char,fg,bg,frame)
  expect(1,x,"number")
  expect(2,y,"number")
  expect(3,char,"string","table")
  expect(4,fg,"string","number","nil")
  expect(5,bg,"string","number","nil")
  expect(6,frame,"number","nil")
  if type(char) == "table" then
    field(char,1,"string")
    field(char,2,"string","number")
    field(char,3,"string","number")
    field(char,4,"number","nil")
  end
  frame = frame or (type(char)=="string" and char[4]) or 1
  if not self.data[frame] or not self.data[frame][y] or #self.data[frame][y][1]<x then
    return
  else
    if type(char) == "table" then
      fg = char[2]
      bg = char[3]
      char = char[1]
    end
    if type(fg) == "number" then fg = colours.toBlit(fg) end
    if type(bg) == "number" then bg = colours.toBlit(bg) end

    local line = self.data[frame][y]
    local newChar = line[1]:sub(1,x-1) .. char .. line[1]:sub(x+1,#line[1])
    local newFg = line[2]:sub(1,x-1) .. fg .. line[2]:sub(x+1,#line[2])
    local newBg = line[3]:sub(1,x-1) .. bg .. line[3]:sub(x+1,#line[3])
    self.data[frame][y] = {
      newChar,
      newFg,
      newBg,
    }
  end
end

--- Set a line of characters.
-- @tparam[1] number y Y coordinate of the line.
-- @tparam[1] string char Characters to set.
-- @tparam[1] string fg Foreground blit colour.
-- @tparam[1] string bg Background blit colour.
-- @tparam[1] number frame Frame to set, defaults to 1.
-- @tparam[2] number y Y coordinate of the pixel.
-- @tparam[2] {string,string,string,number} Table describing a blit line. This follows the same parameters as before.
function image:setLine(y,char,fg,bg,frame)
  expect(1,y,"number")
  expect(2,char,"string","table")
  expect(3,fg,"string","nil")
  expect(4,bg,"string","nil")
  expect(5,frame,"number","nil")
  if type(char) == "table" then
    field(char,1,"string")
    field(char,2,"string")
    field(char,3,"string")
    field(char,4,"number")
  end
  frame = frame or (type(char)=="string" and char[4]) or 1
  if self.data[frame] or not self.data[frame][y] then
    return
  else
    if type(char) == "string" then
      char = {char,fg,bg}
    end
    self.data[frame][y] = char
  end
end

--- Get a pixel.
-- @tparam number x X coordinate of the pixel.
-- @tparam number y Y coordinate of the pixel.
-- @tparam[opt] number frame Frame to get, defaults to 1. 
-- @treturn[1] string Character of the pixel.
-- @treturn[1] string Foreground colour of the pixel.
-- @treturn[1] string Background colour of the pixel.
-- @treturn[2] nil Pixel does not exist in the image.
function image:getPixel(x,y,frame)
  expect(1,x,"number")
  expect(2,y,"number")
  expect(3,frame,"number","nil")
  frame = frame or 1
  if self.data[frame] or not self.data[frame][y] or #self.data[frame][y][1]<x then
    return nil
  else
    local line = self.data[frame][y]
    return line[1]:sub(x,x), line[2]:sub(x,x), line[3]:sub(x,x)
  end
end

--- Get a line.
-- @tparam number y Y coordinate of the line.
-- @tparam[opt] number frame Frame to get, defaults to 1. 
-- @treturn[1] string Characters of the line.
-- @treturn[1] string Foreground colours of the line.
-- @treturn[1] string Background colours of the line.
-- @treturn[2] nil Line does not exist in the image.
function image:getLine(y,frame)
  expect(1,y,"number")
  expect(2,frame,"number","frame")
  if not self.data[frame] or not self.data[frame][y] then
    return nil
  else
    return table.unpack(self.data[frame][y])
  end
end

--- Resize the image.
-- @tparam string method Method used to resize the image.
-- Valid methods are:
-- - `"black"`: Fills in empty space with just black characters.
-- - `"repeat"`: Repeats the last row/column data for the empty space.
-- - `"transparent"`: Fills the empty space with completely invisible characters.
function image:resize(method)
  expect(1,method,"string")
  local methods = {

  }
end

--- Refresh the image from the file.
-- This simply reads the file again.
function image:reload()
  local f = assert(fs.open(self.path,self.binary and "rb" or "r"))
  self.data = textutils.unserialize(f.readAll())
  f.close()
end

--- Save the image to the file.
-- @tparam[opt] string path A new path to save to. Defaults to the original path of the image.
function image:save(path)
  expect(1,path,"string","nil")
  path = path or self.path

  local f = assert(fs.open(path,self.binary and "wb" or "w"))
  f.write(textutils.serialize(self.data))
  f.close()
end

--- Instantiate a new @{Image} object.
-- @tparam string path Path to the image.
-- @tparam boolean binary Whether or not the image was written in binary mode.
-- @treturn Image the new image object.
local function new(path,binary)
  -- Typechecking
  expect(1,path,"string")
  assert(fs.exists(path),"Image path \""..path.."\" does not exist!")

  -- Read image
  local f = assert(fs.open(path,binary and "rb" or "r"))
  local data = textutils.unserialize(f.readAll())
  f.close()

  -- Create object
  local image = {
    path=path,
    data = data,
    binary=binary,
  }
  return setmetatable(image,mt)
end

return setmetatable(
  {new=new},
  {__call=function(_,...) return new(...) end}
)