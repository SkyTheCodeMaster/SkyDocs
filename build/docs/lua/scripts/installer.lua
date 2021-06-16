local h,err = http.get("https://pastebin.com/raw/6UV4qfNF")
if err then error("Something went wrong whilst downloading sha256!") end
local content = h.readAll() h.close()
local sha256 = load(content,"=sha256-package","t",_ENV)()
local expect = require("cc.expect").expect

-- Parse a `requirements.json` local file, or url.
local requirementsFile = ...

local function hread(url)
  local h,err = http.get(url)
  if not h then error("Error downloading " .. url .. ": " .. err) end
  local contents = h.readAll() h.close()
  return contents
end

local function fread(file)
  local f,err = fs.open(file,"r")
  if not f then error("Error opening " .. file .. ": " .. err) end
  local contents = f.readAll() f.close()
  return contents
end

local function fwrite(file,contents)
  local f,err = fs.open(file,"r")
  if not f then error("Error opening " .. file .. ": " .. err) end
  f.write(contents) f.close()
end

--- Compare 2 sha256 hashes of a url and file.
-- @tparam string file File to get hash of.
-- @tparam string url URL to get hash of.
-- @treturn boolean Whether or not the files are the same.
local function compareHash(file,url)
  if not fs.exists(file) then
    return false
  end
  local fileContents = fread(file)
  local fileHash = sha256.digest(fileContents):toHex()
  local urlContents = hread(url)
  local urlHash = sha256.digest(urlContents):toHex()
  return fileHash == urlHash
end

-- It's a URL. Let's download it.
local encJSON = requirementsFile:match("https://") and hread(requirementsFile) or fread(requirementsFile)
local requirements = textutils.unserializeJSON(encJSON) -- Decode the requirements and store it in `decRequirements`
if not requirements then
  error("Couldn't unserialize requirements!")
end

--- Split a string by it's separator.
-- @tparam string inputstr String to split.
-- @tparam string sep Separator to split the string by.
-- @treturn table Table containing the split string.
local function split(inputstr, sep)
  expect(1,inputstr,"string")
  expect(1,sep,"string","nil")
  sep = sep or "%s"
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
          table.insert(t, str)
  end
  return t
end

-- Will get  all files in a directory, with a download link and path.
local function getFiles(recursive,url)
  local splitURL = split(url,"/")
  local apiURL = ("https://api.github.com/repos/%s/%s/contents/%s?ref=%s"):format(splitURL[3], splitURL[4], table.concat(splitURL, "/", 7), splitURL[6]) -- Thanks, JackMacWindows!
  local contents = textutils.unserializeJSON(hread(apiURL))
  local files = {}
  for _,v in pairs(contents) do
    if v.type == "dir" and recursive then
      local newFiles = getFiles(true,v["_links"].self)
      for _,file in pairs(newFiles) do table.insert(files,file) end
    end
    if v.type == "file" then
      table.insert(files,{url=v.download_url,path=v.path})
    end
  end
end

-- Download the output of getFiles.
local function downloadFiles(files)
  for _,v in pairs(files) do
    if compareHash(v.path,v.url) then
      local content = hread(v.url)
      print("Downloading",v.path)
      fwrite(v.path,content)
    end
  end
end

for url,data in pairs(requirements) do
  if not data.folder then
    -- Easy, just download file into specified path.
    if not compareHash(data.path,url) then -- If the files are different, collect the new one.
      print("Collecting",data.path)
      fwrite(data.path,hread(url))
    end
  else
    local folder = getFiles(data.recursive,url)
    downloadFiles(folder)
  end
  print("Collected",data.path)
end