--- log is a library to simply write logs to a file.
-- This library will be soon rewritten in favour of objects, instead of the library holding them.
-- @module[kind=skyos] log

local mLog
local LFT = {} -- Log File Table
local log = {}

--- new creates a new log, and adds it to the table of logs
-- @tparam string path path to the log file
-- @tparam string name name of the log file
function log.new(logPath,logName)
  LFT[tostring(logName)] = fs.open(logPath,"a")
end

--- save saves the log
-- @tparam name name of the log to save
function log.save(logName)
  if logName == nil then logName = mLog end
  LFT[tostring(logName)].flush()
end

--- close closes the log file
-- @tparam string name name of the log to close
function log.close(logName)
  if logName == nil then logName = mLog end
  LFT[tostring(logName)].close()
end

--- info logs "[INFO] text" in the log file
-- @tparam string text text to write in the log
-- @tparam string name name of the log to write
function log.info(text,logName)
  if logName == nil then logName = mLog end
  t = os.date("*t")
  curTime = "[" .. string.gsub(os.date("%x"),"/",":") .. ":" .. os.date("%X") .. "]"
  LFT[tostring(logName)].writeLine(curTime.." [INFO] "..tostring(text))
end

--- warn logs "[WARN] text" in the log file
-- @tparam string text text to write in the log
-- @tparam string name name of the log to write
function log.warn(text,logName)
  if logName == nil then logName = mLog end
  t = os.date("*t")
  curTime = "[" .. string.gsub(os.date("%x"),"/",":") .. ":" .. os.date("%X") .. "]"
  LFT[tostring(logName)].writeLine(curTime.." [WARN] "..tostring(text))
end

--- error logs "[ERROR] text" in the log file
-- @tparam {string|number} id error ID
-- @tparam string text text to write in the log
-- @tparam string name name of the log to write
function log.error(errorID,errorInfo,logName)
  if logName == nil then logName = mLog end
  t = os.date("*t")
  curTime = "[" .. string.gsub(os.date("%x"),"/",":") .. ":" .. os.date("%X") .. "]"
  LFT[tostring(logName)].writeLine(curTime.." [ERROR] "..tostring(errorID)..":"..tostring(errorInfo))
end

--- errorC calls {@log.error} and closes the log file
-- @tparam {string|number} id error ID
-- @tparam string info error info
-- @tparam string name name of the log
function log.errorC(errorID,errorInfo,logName)
  if logName == nil then logName = mLog end
  log.error(errorID,errorInfo,logName)
  log.save(logName)
  log.close(logName)
  error(tostring(errorInfo).." See log for more")
end

-- setMain sets the default log to write to
-- @tparam string name name of the log to set as default
function log.setMain(logName)
  mLog = logName
end

--- activeLogs returns the open log files 
-- @treturn table active log files
function log.activeLogs()
  return LFT
end

return log