--- roll20 is just a library of various functions to condition text & files into roll20 macros/statements
-- @module[kind=misc] roll20

--- Swap out characters for the code equivalent `&#` character.
-- @tparam string str The string to condition.
-- @treturn string outputStr The resultant string.
local function conditionCharacters(str)
  local outputStr = str:gsub("|","&#124;"):gsub(",","&#44"):gsub("}","&#125;")
  return outputStr
end

--- Takes a prompt and a table of choices, and generates a roll20 prompt string.
-- @tparam string promptName The prompt text.
-- @tparam table choices The various choices and outputs of the choices
-- @treturn string The resultant string.
local function makePrompt(promptName,choices)
  local str = "?{" .. promptName
  for k,v in pairs(choices) do
    str = str .. "|" .. tostring(k) .. "," .. tostring(v)
  end
  str = str .. "}"
  return str
end

--- Take some parameters, spit out a dice roll string.
-- @tparam string numDice How many dice to roll.
-- @tparam string diceSides How many sides of the die.
-- @tparam string modifier Modifier of the dice roll.
-- @tparam boolean inline Whether or not to make it an inline dice roll.
-- @treturn string roll The roll string that can be ran in Roll20.
local function makeDiceRoll(numDice,diceSides,modifier,inline)
  local str = ""
  if inline then str = str .. "[[" end
  str = str .. numDice .. "D" .. diceSides .. "+" .. modifier
  if inline then str = str .. "]]" end
  return str
end

return {
  conditionCharacters = conditionCharacters,
  makePrompt = makePrompt,
  makeDiceRoll = makeDiceRoll,
}