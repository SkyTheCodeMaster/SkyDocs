--- This library will handle crash reports, generating crash reports.
-- @module[kind=skyos] crash

local expect = require("cc.expect").expect

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

--- Generates a filepath to save to.
-- @tparam string folder Folder to save into, or initial path.
-- @tparam string extension Filetype to save as.
-- @treturn string Filepath, eg. `folder/hhmmss-ddmmyyyy.extension`.
local function genTimeString(folder,extension)
  expect(1,folder,"string")

  local offset
  if SkyOS and SkyOS.settings and SkyOS.settings.timezone then
    offset = SkyOS.settings.timezone
  else
    offset = 0
  end
  local epoch = math.floor(os.epoch("utc") / 1000) + (3600 * offset)
  local t = os.date("!*t",epoch)
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
  local filepath = fs.combine(folder, time.hour .. time.min .. time.sec .. "-" .. time.day .. time.month .. time.year .. "." .. extension)
  return filepath
end

--- Generate system details, this includes things like disk used, etc.
-- @treturn table System information.
local function systemInformation()
  local diskused = getSize(".")
  local disksize = fs.getCapacity(".")
  local label = os.getComputerLabel()
  local id = os.getComputerID()
  local craftos = os.version()
  local lua = _VERSION
  local host = _HOST
  local skyosVersion = SkyOS and SkyOS.version or "Unknown"
  local diagstr = string.format("DIAGNOSTIC DETAILS:\nDisk used: %d/%d\nLabel: %s\nID: %d\nCC: %s\nLua: %s\nHost: %s\nSkyOS: %s",diskused,disksize,label,id,craftos,lua,host,skyosVersion)
  return diagstr 
end

local function crashreport(stacktrace)
  local diagstr = systemInformation()
  local crashstr = string.format("---DIAGNOSTIC INFORMATION---\n%s\n---STACKTRACE---\n%s",diagstr,stacktrace)
  local file = genTimeString("crash-reports","log")
  local f = fs.open(file,"w")
  f.write(crashstr) 
  f.close()
end

return setmetatable({crashreport = crashreport},{["__call"] = function(_,...) return crashreport(...) end})