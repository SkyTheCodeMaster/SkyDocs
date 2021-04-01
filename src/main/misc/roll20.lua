--- roll20 is just a library of various functions to condition text & files into roll20 macros/statements
-- @module[kind=misc] roll20

--- conditionCharacters swaps out characters for code equivalent, making them not mess up the macro.
-- @tparam string str The string to condition.
-- @treturn string outputStr The resultant string.
local function conditionCharacters(str)
  local outputStr = str:gsub("|","&#124;"):gsub(",","&#44"):gsub("}","&#125;")
  return outputStr
end

--- makePrompt takes a prompt name and a table of choices, and assembles a roll20 prompt
-- @tparam string promptName The prompt text.
-- @tparam table choices The various choices and outputs of the choices
-- @treturn string The resultant string.
local function makePrompt(promptName,choices)
  local str = "?{" .. promptName
  for k,v in pairs(choices) do
    str = str .. "|" .. tostring(k) .. "," .. tostring(v)
  end
  return str
end

return {
  conditionCharacters = conditionCharacters,
  makePrompt = makePrompt,
}