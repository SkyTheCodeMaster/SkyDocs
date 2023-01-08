--- An API that connects to the `ccsql` server and allows requests.
-- @module[kind=misc] ccsql
local ccsql = {}

local expect = require("cc.expect").expect

local HOST = "wss://ccsql.skystuff.games"

--- Connection object.
local connection = {} --- @type Connection
local mt = {
  __index = connection
}

--- Fetch rows from query.
-- @tparam string query The main query of the request. For sanitization, replace any parameters with `$n`, and pass those arguments after the query.
-- @treturn table A table of table objects that represent each row of the request.
function connection:fetch(query,...)
  local json = textutils.serializeJSON({query,...})
  self.ws.send(json)
  local resp = textutils.unserializeJSON(self.ws.receive())
  return resp
end

--- Fetch the first row from the query.
-- @tparam string query The main query of the request. For sanitization, replace any parameters with `$n`, and pass those arguments after the query.
-- @treturn table A table that represents the returned row of the request.
function connection:fetchrow(query,...)
  local json = textutils.serializeJSON({query,...})
  self.ws.send(json)
  local resp = textutils.unserializeJSON(self.ws.receive())
  return resp[1]
end

--- Execute a statement and ignore the result..
-- @tparam string query The main query of the request. For sanitization, replace any parameters with `$n`, and pass those arguments after the query.
function connection:execute(query,...)
  local json = textutils.serializeJSON({query,...})
  self.ws.send(json)
  self.ws.receive() -- Drop the result.
end

--- Close the connection. This makes every function error.
function connection:close()
  self.ws.close()
  local function closed() error("This connection is closed.",0) end
  self.fetch = closed
  self.fetchrow = closed
  self.execute = closed
end
--- Opens a connection to the requested Postgresql server.
-- @tparam string host URL of the psql server. Must start with `postgresql://`!
-- @tparam[opt] string username Username of the account of the psql server.
-- @tparam[opt] string password Password of the account of the psql server.
-- @treturn Connection
-- @return[2] false If the connection failed.
function ccsql.open(host,username,password)
  expect(1,host,"string")
  expect(2,username,"string","nil")
  expect(3,password,"string","nil")
  local ws = http.websocket(HOST)
  -- Initialize the connection.
  ws.send(textutils.serializeJSON({url=host,username=username,password=password,connect=true}))
  local resp = ws.receive()
  if resp ~= "ok" then
    return false
  end

  local conn = {ws=ws}

  return setmetatable(conn,mt)
end

return ccsql