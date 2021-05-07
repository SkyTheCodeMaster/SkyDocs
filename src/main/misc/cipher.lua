--- Provides various cipher functions, such as a Caesar cipher, and Viginere cipher.
-- @module[kind=misc] cipher

-- Setup local functions
local expect = require("cc.expect").expect -- Ensure that fields are correct.

local function cut(str,len,pad) -- Shorten viginere keys.
  pad = pad or " "
  return str:sub(1,len) .. pad:rep(len - #str)
end

-- Very big table
--- Just a numerically indiced table that contains every letter of the alphabet (English alphabet.)
local letterTable = {
  "a", "b", "c", "d", "e",
  "f", "g", "h", "i", "j",
  "k", "l", "m", "n", "o",
  "p", "q", "r", "s", "t",
  "u", "v", "w", "x", "y",
  "z",
}

--- A table where a number turns into a letter. (English alphabet.)
local numberTable = {}
for k, v in pairs(letterTable) do
  numberTable[v] = k
end

--- Shift a single letter by a modifier.
-- @tparam string letter Letter to modify.
-- @tparam number modifier How many letters to shift it by.
-- @treturn string Shifted letter.
local function shiftLetter(letter,modifier)
  -- Do type checking
  expect(1,letter,"string")
  expect(2,modifier,"number")
  if letter == " " then return " " end
  -- Get the index of the input letter
  local letterIndex = numberTable[letter]
  -- Add the modifier to the letter index
  local newIndex = letterIndex + modifier
  -- Return the index, between 1 and 26
  return letterTable[(newIndex % 26)]
end

--- Run a Caesar Cipher on the provided string. (https://en.wikipedia.org/wiki/Caesar_cipher)
-- @tparam string input String to cipher.
-- @tparam[opt=-3] number shift Amount of letters to shift the string by.
-- @treturn string Ciphered string.
local function caesar(input,shift)
  -- Do type checking
  expect(1,input,"string")
  expect(2,shift,"number","nil")
  -- Default the shift if not present
  shift = shift or -3
  -- Remove the invalid letters from a string.
  input = input:gsub("%A","")
  local outTbl = {}
  -- Loop through every letter in the string
    for x in input:lower():gmatch(".") do
    -- Shift the letter and insert it into the table
    local shifted = shiftLetter(x,shift)
    table.insert(outTbl,shifted)
  end
  -- Concatenate the entire table into a single string
  local final = table.concat(outTbl)
  return final
end

--- Run a Viginere cipher on the provided string. (https://en.wikipedia.org/wiki/Vigen%C3%A8re_cipher)
-- @tparam string input String to cipher.
-- @tparam string key Key to cipher the string with.
-- @treturn string The ciphered string.
local function viginere(input,key)
  -- Do type checking
  expect(1,input,"string")
  expect(2,input,"string")
  -- Check the key length against the input.
  local cutKey -- Cut to length key
  if key:len() < input:len() then -- If the key length is shorter than the input, repeat the key.
    -- Determine amount of repeats
    local repeatAmount = math.ceil(input:len() / key:len())
    cutKey = cut(key:rep(repeatAmount),input:len()) -- Then cut the key to the to the length of the key.
  elseif key:len() > input:len() then -- If the key length is longer than the input, cut the key.
    cutKey = cut(key,input:len())
  else
    cutKey = key
  end
  -- Tables to store the numbers in the tables.
  local inputNumbers = {}
  local keyNumbers = {}
  local combined = {}
  for x in input:gmatch(".") do
    if x == " " then
      table.insert(inputNumbers," ")
    else
      local index = numberTable[x]
      table.insert(inputNumbers,index)
    end
  end
  for x in cutKey:gmatch(".") do
    if x == " " then
      table.insert(inputNumbers," ")
    else
      local index = numberTable[x]
      table.insert(keyNumbers,index)
    end
  end
  -- Loop through the table, and combine the key and input.
  for i=1,#inputNumbers do
    if inputNumbers[i] == " " then
      table.insert(combined," ")
    else
      local inLet = inputNumbers[i]-1
      local keyLet = keyNumbers[i]-1
      local outNum = inLet + keyLet
      local outLet = letterTable[(outNum % 26)+1]
      table.insert(combined,outLet)
    end
  end
  -- Combined string
  local outString = table.concat(combined)
  return outString
end

--- Reverse a Viginere cipher on the provided string. (https://en.wikipedia.org/wiki/Vigen%C3%A8re_cipher)
-- @tparam string input String to decipher.
-- @tparam string key Key to decipher the string with.
-- @treturn string The deciphered string.
local function viginerDecode(input,key)
    -- Do type checking
    expect(1,input,"string")
    expect(2,input,"string")
    -- Check the key length against the input.
    local cutKey -- Cut to length key
    if key:len() < input:len() then -- If the key length is shorter than the input, repeat the key.
      -- Determine amount of repeats
      local repeatAmount = math.ceil(input:len() / key:len())
      cutKey = cut(key:rep(repeatAmount),input:len()) -- Then cut the key to the to the length of the key.
    elseif key:len() > input:len() then -- If the key length is longer than the input, cut the key.
      cutKey = cut(key,input:len())
    else
      cutKey = key
    end
    -- Tables to store the numbers in the tables.
    local inputNumbers = {}
    local keyNumbers = {}
    local combined = {}
    for x in input:gmatch(".") do
      local index = numberTable[x]
      table.insert(inputNumbers,index)
    end
    for x in cutKey:gmatch(".") do
      local index = numberTable[x]
      table.insert(keyNumbers,index)
    end
    -- Loop through the table, and combine the key and input.
    for i=1,#inputNumbers do
      local inLet = inputNumbers[i]-1
      local keyLet = keyNumbers[i]-1
      local outNum = inLet - keyLet
      if outNum < 0 then outNum = outNum + 26 end
      local outLet = letterTable[(outNum % 26)+1]
      table.insert(combined,outLet)
    end
    -- Combined string
    local outString = table.concat(combined)
    return outString
end

--- Run a ROT13 cipher on the input. (https://en.wikipedia.org/wiki/ROT13)
-- @tparam string input The string to cipher.
-- @tparam output The ciphered string. 
local function rot13(input)
  return caesar(input,13)
end

return {
  letterTable = letterTable,
  numberTable = numberTable,
  shiftLetter = shiftLetter,
  caesar = caesar,
  viginere = viginere,
  viginereDecode = viginerDecode,
  rot13 = rot13,
}