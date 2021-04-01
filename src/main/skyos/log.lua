--- The log library is a library to store logs for various programs. It will keep the logs down to a certain size.
-- @module[kind=skyos] log

local function genTime()
  local time = os.date("!*t")
  local str = "["..tostring(t.hour)..":"..tostring(t.min)..":"..tostring(t.sec).."] "
  return str
end

local tbl = {}
local mt = {["__index"] = tbl}
function tbl:save() 
  self.fHandle.save()
end
function tbl:close()
  self.fHandle.close()
end
function tbl:info(info)
  local time = genTime()
  local str = time .. "[INFO]" .. info
  fHandle.writeLine(str)
end
function tbl:warn(warn)
  local time = genTime()
  local str = time .. "[INFO]" .. warn
  fHandle.writeLine(str)
end
function tbl:err(err)
  local time = genTime()
  local str = time .. "[INFO]" .. err
  fHandle.writeLine(str)
end
--- create returns a table of functions for writing to a log file.
-- @tparam string file Path to the log file.
local function create(file)
  local fHandle,err = fs.open(file,"w")
  if not fHandle then return nil,err end
  local tbl = {
    fHandle = fHandle
  }
  return setmetatable(tbl,mt)
end