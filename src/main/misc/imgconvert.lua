--- Convert skimg to other filetypes, and other filetypes to skimgs.
-- @module[kind=misc] imgconvert

-- make attributes for skimg files, returns {x=x,y=y,creator="skimgConvert",locked=false,type=1}
local function generateAttributes(blit)
  local x = string.len(blit[1][1])
  local y = #blit
  return {x=x,y=y,creator="skimgConvert",locked=false,type=1}
end
-- add y level to each subtable
local function addY(blit)
  for i=1,#blit do
    blit[i][4] = i
  end
  return blit
end
-- skimg to (blit,limg)
--- Convert a `skimg` image to a `blit` image.
-- @tparam table skimg `skimg` image.
-- @treturn table `blit` image.
local function skimgblit(skimg)
  if not skimg or not skimg.data then
    error("Input table is not a skimg!")
  end
  return skimg.data
end

--- Convert a `skimg` image to a `limg` image.
-- @tparam table skimg `skimg` image.
-- @treturn table `limg` image.
local function skimglimg(skimg)
  if not skimg or not skimg.data then
    error("Input table is not a skimg!")
  end
  return {skimg.data}
end

-- blit to (skimg,limg)
--- Convert a `blit` image to a `skimg` image.
-- @tparam table blit `blit` image.
-- @tparam table `skimg` image.
local function blitskimg(blitImage)
  return {attributes = generateAttributes(blitImage),data=addY(blitImage)}
end

--- Convert a `blit` image to `limg` image.
-- @tparam table blit `blit` image.
-- @treturn table `limg` image.
local function blitlimg(blitImage)
  return {blitImage}
end

-- limg to (skimg,blit)
--- Convert a `limg` into `skimg`.
-- @tparam table limg `limg` image.
-- @treturn table `skimg` image.
local function limgskimg(limg)
  local image = limg[1]
  return {attributes = generateAttributes(image),data=addY(image)}
end

--- Convert a `limg` into `blit`.
-- @tparam table limg `limg` image.
-- @treturn table `blit` image.
local function limgblit(limg)
  return limg[1]
end

return {
  --- `skimg` functions.
  skimg = {
    blit = skimgblit,
    limg = skimglimg,
  },
  --- `blit` functions.
  blit = {
    skimg = blitskimg,
    limg = blitlimg,
  },
  --- `limg` functions.
  limg = {
    skimg = limgskimg,
    blit = limgblit,
  },
}