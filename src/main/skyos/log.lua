--- The log library is a library to store logs for various programs. It will keep the logs down to a certain size.
-- @module[kind=skyos] log

local function genTime()
  local t = os.date("!*t")
  local str = "["..tostring(t.hour)..":"..tostring(t.min)..":"..tostring(t.sec).."] "
  return str
end

local tbl = {} --- @type log
local mt = {["__index"] = tbl}
--- Save the log, writing all the written info to the file. 
function tbl:save() 
  self.fHandle.save()
end
--- Close the log, stopping further use.
function tbl:close()
  self.fHandle.close()
end
--- Writes an info line to the log.
-- @tparam string info The info to write to the log.
function tbl:info(info)
  local time = genTime()
  local str = time .. "[INFO]" .. info
  self.fHandle.writeLine(str)
end
--- Writes a warn line to the log.
-- @tparam string warn The warn to write to the log.
function tbl:warn(warn)
  local time = genTime()
  local str = time .. "[INFO]" .. warn
  self.fHandle.writeLine(str)
end
--- Writes an errorline to the log.
-- @tparam string error The error to write to the log.
function tbl:err(err)
  local time = genTime()
  local str = time .. "[INFO]" .. err
  self.fHandle.writeLine(str)
end
--- Create returns a table of functions for writing to a log file.
-- @tparam string file Path to the log file.
-- @treturn table log Logwith functions to write to the log file.
local function create(file)
  local fHandle,err = fs.open(file,"w")
  if not fHandle then return nil,err end
  local tbl = {
    fHandle = fHandle
  }
  return setmetatable(tbl,mt)
end

return {
  create = create,
}