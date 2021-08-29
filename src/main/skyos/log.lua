--- Logging library for SkyOS. This is similar *ish* to Python's `logging`.
-- @module[kind=skyos] log

local expect = require("cc.expect").expect

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

--- Debug log level, these should be treated as debug `print` statements.
local DEBUG = 0
--- Info log level, these should be used for logging general information.
local INFO = 1
--- Warning log level, these should be used if something isn't right.
local WARNING = 2
--- Error log level, these should be used if something breaks.
local ERROR = 3
--- Critical log level, these should be used if something goes very wrong.
local CRITICAL = 4

local levelLookup = {
  [0] = "DEBUG",
  "INFO",
  "WARNING",
  "ERROR",
  "CRITICAL",
}

local logs = {}

--- The actual LOG object that's returned when creating a log
-- @type LOG
local LOG = {
  --- Configuration of the log, it is recommended that you edit this through the provided functions.
  config={
    --- File to log to.
    file = "log.txt",
    --- Format of log lines.
    format = "[{asctime}][{level}] {message}",
    --- Date format.
    datefmt = "%Y/%m/%d-%H:%M:%S",
    --- Level of the logger.
    level = 1, -- INFO level
    --- Enabled.
    enabled = true,
  },
}

--- Setup the logger, with specified formats
-- @tparam string file Path to log file. Written in append mode.
-- @tparam string format Format of log lines.
-- @tparam string datefmt Date format, if used in `format`. This is the same format as C's `strftime` function. (http://www.cplusplus.com/reference/ctime/strftime/)
-- @tparam number level Level to report as. Hierarchy goes as: Debug -> Info -> Warning -> Error -> Critical.
function LOG.basicConfig(file,format,datefmt,level)
  expect(1,file,"string")
  expect(2,format,"string")
  expect(3,datefmt,"string")
  expect(4,level,"number")

  --- File to log to.
  LOG.config.file = file
  --- Format of log lines.
  LOG.config.format = format
  --- Date format.
  LOG.config.datefmt = datefmt
  --- Level of the logger.
  LOG.config.level = level
end

--- Set the level of the logger.
-- @tparam number level Level to report as. Hierarchy goes as: Debug -> Info -> Warning -> Error -> Critical.
function LOG.setLevel(level)
  expect(1,level,"number")
  --- Level of the logger.
  LOG.config.level = level
end

--- Set the format of the logger.
-- @tparam string format Format of log lines.
function LOG.setFormat(format)
  expect(1,format,"string")
  --- Format of log lines.
  LOG.config.format = format
end

--- Set the date format of the logger.
-- @tparam string datefmt Date format, if used in `format`. This is the same format as C's `strftime` function. (http://www.cplusplus.com/reference/ctime/strftime/)
function LOG.setDatefmt(datefmt)
  expect(1,datefmt,"string")
  --- Date format.
  LOG.config.datefmt = datefmt
end

--- Enable or disable the logger. If the logger is disabled then lines will not be written to the file.
-- @tparam boolean enabled Whether or not the logger is enabled.
function LOG.enable(enabled)
  expect(1,enabled,"boolean")
  --- Enabled
  LOG.config.enabled = enabled
end

--- Write a message to the specified log file.
-- @tparam table log The log to write.
-- @tparam number level The level of the log message.
-- @tparam string message The log message itself.
-- @treturn[1] true The log was successful.
-- @treturn[2] false The log was unsuccessful.
-- @treturn[2] string Why the log was unsuccessful.
local function writeLog(log,level,message)
  expect(1,log,"table")
  expect(2,level,"number")
  expect(3,message,"string")

  if log.config.enabled then
    if log.level >= level then -- Yep, this is reportable.
      local f,err = fs.open(log.config.file,"a")
      if not f then return false,err end
      local time = os.date(log.config.datefmt)
      local fmt = log.config.format:gsub("{asctime}",time):gsub("{level}",levelLookup[level]):gsub("{message}",message)
      f.write(fmt .. "\n")
      return true
    end
  else
    return false,"logger not enabled"
  end
  return false,"level too low"
end

--- Log a DEBUG level message to the file.
-- @tparam string message The message to log.
-- @treturn[1] true The log was successful.
-- @treturn[2] false The log was unsuccessful.
-- @treturn[2] string Why the log was unsuccessful.
function LOG.debug(message)
  return writeLog(LOG,DEBUG,message)
end

--- Log an INFO level message to the file.
-- @tparam string message The message to log.
-- @treturn[1] true The log was successful.
-- @treturn[2] false The log was unsuccessful.
-- @treturn[2] string Why the log was unsuccessful.
function LOG.info(message)
  return writeLog(LOG,DEBUG,message)
end

--- Log a WARNING level message to the file.
-- @tparam string message The message to log.
-- @treturn[1] true The log was successful.
-- @treturn[2] false The log was unsuccessful.
-- @treturn[2] string Why the log was unsuccessful.
function LOG.warning(message)
  return writeLog(LOG,WARNING,message)
end

--- Log an ERROR level message to the file.
-- @tparam string message The message to log.
-- @treturn[1] true The log was successful.
-- @treturn[2] false The log was unsuccessful.
-- @treturn[2] string Why the log was unsuccessful.
function LOG.error(message)
  return writeLog(LOG,ERROR,message)
end

--- Log a CRITICAL level message to the file.
-- @tparam string message The message to log.
-- @treturn[1] true The log was successful.
-- @treturn[2] false The log was unsuccessful.
-- @treturn[2] string Why the log was unsuccessful.
function LOG.critical(message)
  return writeLog(LOG,CRITICAL,message)
end

--- Create a logger, with a specified name.
-- @tparam string name Name of the logger.
-- @treturn LOG Log object.
local function create(name)
  logs[name] = deepCopy(LOG)
  return logs[name]
end

--- Get a logger, or create one if it doesn't exist.
-- @tparam string name Name of the logger.
-- @treturn LOG Log object.
local function getLogger(name)
  if logs[name] then
    return logs[name]
  else
    logs[name] = deepCopy(LOG)
    return logs[name]
  end
end

return {
  create = create,
  getLogger = getLogger,
  DEBUG = DEBUG,
  INFO = INFO,
  WARNING = WARNING,
  ERROR = ERROR,
  CRITICAL = CRITICAL,
}