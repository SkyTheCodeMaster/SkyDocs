--- Provides a devbin api to interact with devbin without using the devbin shell command.
-- @module[kind=misc] devbin

-- TODO: Fix `put`, as it errors with `Unsupported Media Type`. Maybe set `Content-Type` in headers?

local api = "https://beta.devbin.dev/api/v2/"

local function extractId(paste)
  local patterns = {
      "^([%a%d]+)$",
      "^https?://beta,devbin.dev/([%a%d]+)$",
      "^beta.devbin.dev/([%a%d]+)$",
      "^https?://beta.devbin.dev/raw/([%a%d]+)$",
      "^beta.devbin.dev/raw/([%a%d]+)$",
  }

  for i = 1, #patterns do
      local code = paste:match(patterns[i])
      if code then return code end
  end

  return nil
end

--- Get a string from devbin.
-- @tparam string id The paste id that you want to download.
-- @treturn string|nil The string containing the paste, or nil.
-- @treturn nil|string The reason why it couldn't be retrieved.
local function get(url)
  local paste = extractId(url)
  if not paste then
      return nil, "invalid"
  end
  -- Add a cache buster so that spam protection is re-checked
  local cacheBuster = ("%x"):format(math.random(0, 2 ^ 30))
  local response, err = http.get(
      api .. "paste/" .. textutils.urlEncode(paste) .. "?cb=" .. cacheBuster
  )

  if response then

      local sResponse = response.readAll()
      response.close()
      local json = textutils.unserializeJSON(sResponse)

      return json.contentCache
  else
      return nil, err
  end
end

--- Put a string on devbin.
-- @tparam string string The string that you want to put on devbin.
-- @tparam[opt] string name The name of the paste, defaults to "CC:T Paste".
-- @treturn string|nil A string containing the id of the paste.
local function put(sText, sName)
  sName = sName or "CC:T Paste"
  -- Upload a file to devbin
  local key = "computercraft"
  local body = textutils.serializeJSON({
    title=sName,
    syntax="lua",
    exposure="Public",
    content=sText,
    asGuest=true,
  })
  local response = http.post(
    api .. "create?token=" .. key,
    body
  )

  if response then

    local sResponse = response.readAll()
    response.close()

    local sCode = string.match(sResponse, "[^/]+$")
    return sCode
  else
    return nil
  end
end

return {
  get = get,
  put = put,
}