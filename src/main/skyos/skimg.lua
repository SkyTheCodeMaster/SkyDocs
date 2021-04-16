--- This is just the `skimg` parts of {@sUtils}, to load a little quicker when starting SkyOS and displaying images.
-- @module[kind=skyos] skimg

local expect = require("cc.expect").expect

--- Load a skimg from a file.
-- @tparam string path Path to the skimg file.
-- @treturn table The loaded skimg.
local function load(path)
  local f = fs.open(path,"r")
  local skimg = textutils.unserialize(f.readAll())
  f.close()
  return skimg
end

--- Draw a skimg.
-- @tparam table skimg The skimg image to draw.
-- @tparam[opt] number x X coordinate, defaults to 1.
-- @tparam[opt] number y Y coordinate, defaults to 1.
-- @tparam[opt] table output Output terminal, defaults to `term.current()`
local function draw(tbl,x,y,tOutput)
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

return {
  load = load,
  draw = draw,
}