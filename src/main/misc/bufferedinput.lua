--- A direct port of one of my Python libraries. Handles keypresses with a buffer and has a callback for each press.
-- @module[kind=misc] bufferedinput

local expect = require("cc.expect")

--- Read a string, and call the callback each letter, with the buffer as an argument.
-- @tparam { allowKeyboardInterrupt? = boolean, limit? = number, callback? = function}
local function read(options)
  expect(1,options,"table")
  local buffer = ""
  while true do
    local ev,value = os.pullEventRaw()
    if ev == "terminate" and options.allowKeyboardInterrupt then
      error("terminated",0)
    elseif ev == "key" and value == keys.backspace then
      buffer = buffer:sub(1,#buffer-1)
      if options.callback then options.callback(buffer) end
    elseif ev == "key" and value == keys.enter then
      return buffer
    elseif ev == "char" then
      if limit then
        if #buffer < options.limit then
          buffer = buffer .. value
        end
      else
        buffer = buffer .. value
      end
      if options.callback then options.callback(buffer) end
    end
  end
end

return {
  read = read,
}