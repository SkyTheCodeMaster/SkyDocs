--- sos is a library that contains functions pertaining to SkyOS itself
-- @module[kind=skyos] sos

local expect = require("cc.expect").expect

local presets = {
  github = {
    user = "SkyTheCodeMaster",
    repo = "SkyOS",
    branch = "master",
    path = "",
  }
}

-- file functions
local function fread(file)
  expect(1,file,"string")
  local f = fs.open(file,"r")
  local contents = f.readAll()
  f.close()
  return contents
end

local function fwrite(file,contents)
  expect(1,file,"string")
  expect(2,contents,"string")
  local f = fs.open(file,"w")
  f.write(contents)
  f.close()
end

local function encfwrite(file,object)
  local obj = textutils.serialize(object)
  fwrite(file,obj)
end

local function encfread(file)
  local contents = fread(file)
  return textutils.unserialize(contents)
end

local function hread(url)
  expect(1,url,"string")
  local h,err = http.get(url)
  if not h then
    return nil,err
  end
  local contents = h.readAll()
  h.close()
  return contents,nil
end

--- downloadRepo takes a github user, repository, branch, and path to save to, and downloads the repository.
-- @tparam string user Github user to download repository from.
-- @tparam string repo Github repository to download.
-- @tparam string branch Repository branch to download. Defaults to "master".
-- @tparam string path Path to download to. Defaults to "".
-- @treturn number filecount The amount of files in the repository.
-- @treturn number downloaded The amount of files downloaded.
local function downloadRepo(user,repo,branch,path)
  expect(1,user,"string","nil")
  expect(2,repo,"string","nil")
  expect(3,branch,"string","nil")
  expect(4,path,"string","nil")
  user = user or presets.github.user
  repo = repo or presets.github.repo
  branch = branch or presets.github.branch
  path = path or presets.github.path

  local data = textutils.unserializeJSON(hread("https://api.github.com/repos/"..user.."/"..repo.."/git/trees/"..repo.."?recursive=1"))
  
  local filecount = 0
  local downloaded = 0
  local paths = {}
  local failed = {}

  for k,v in pairs(data.tree) do
    -- Send all HTTP requests (async)
    if v.type == "blob" then
      v.path = v.path:gsub("%s","%%20")
      local url = "https://raw.github.com/"..user.."/"..repo.."/"..branch.."/"..v.path,fs.combine(path,v.path)
      http.request(url)
      paths[url] = fs.combine(path,v.path)
      filecount = filecount + 1
    end
  end

  while downloaded < filecount do
    local e, a, b = os.pullEvent()
    if e == "http_success" then
        fwrite(b.readAll(),paths[a])
        downloaded = downloaded + 1
    elseif e == "http_failure" then
        -- Retry in 3 seconds
        failed[os.startTimer(3)] = a
    elseif e == "timer" and failed[a] then
        http.request(failed[a])
    end
  end
  return filecount,downloaded
end

--- updateSkyOS simply updates SkyOS from the github repository
-- @tparam[opt] boolean Reboot after update. Defaults to false.
local function updateSkyOS(reboot)
  expect(1,reboot,"boolean","nil")
  reboot = reboot or false
  downloadRepo()
  if reboot then os.reboot() end
end

return {
  downloadRepo = downloadRepo,
  updateSkyOS = updateSkyOS,
}