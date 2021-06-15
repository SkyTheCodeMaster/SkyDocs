--- sos is a library that contains functions pertaining to SkyOS itself
-- @module[kind=skyos] sos

local expect = require("cc.expect").expect
local sUtils = require("libraries.sUtils")

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
-- @tparam[opt] boolean reboot Reboot after update. Defaults to false.
local function updateSkyOS(reboot)
  expect(1,reboot,"boolean","nil")
  reboot = reboot or false
  downloadRepo()
  if reboot then os.reboot() end
end

--- Check for an app on the specified screen, x, and y position.
-- @tparam number screen Screen to check for the app on.
-- @tparam number x X coordinate to check on the screen.
-- @tparam number y Y coordinate to check on the screen.
-- @treturn[1] table Key value table containing the app's `name`, `program`, `image`, and `args`.
-- @treturn[2] nil If app is not found, returns nil.
local function checkPosition(screen,x,y)
  local desktop = encfread("settings/desktop.dat")
  if not desktop[screen] or not desktop[screen][y] or not desktop[screen][y][x] then return nil end -- Check if the screen doesn't exist, then check if the y line doesn't exist, then check if the x doesn't exist.
  local app = desktop[screen][y][x]
  local tbl = {
    name = app.name,
    image = app.image,
    program = app.program,
    args = app.args,
  }
  return tbl
end

--- Insert an app into the desktop.
-- @tparam string name Name of the app.
-- @tparam string image Path to the image of the app.
-- @tparam string program Path to the program to run.
-- @tparam string args Arguments of the program.
-- @tparam number screen Screen to put it on.
-- @tparam number x X coordinate of the screen to put it on.
-- @tparam number y Y coordinate of the screen to put it on.
local function addApp(name,image,program,args,screen,x,y)
  args = args or ""
  if not checkPosition(screen,x,y) then
    local desktop = encfread("settings/desktop.dat")
    desktop[screen][y][x] = {
      name = name,
      image = image,
      program = program,
      args = args
    }
    encfwrite("settings/desktop.dat",desktop)
  end
end

--- Edit an app on a screen.
-- @tparam number screen Screen of the app.
-- @tparam number x X coordinate of the app.
-- @tparam number y Y coordinate of the app.
-- @tparam[opt] string name Name to change to, defaults to previous name.
-- @tparam[opt] string image Path to the image, defaults to previous path.
-- @tparam[opt] string program Path to the program, defaults to the previous path.
-- @tparam[opt] string args Arguments of the program, defaults to previous arguments.
local function editApp(screen,x,y,name,image,program,args)
  local app = checkPosition(screen,x,y)
  if app then
    local desktop = encfread("settings/desktop.dat")
    name = name or app.name
    image = image or app.image
    program = program or app.program
    args = args or app.args
    desktop[screen][y][x] = {
      name = name,
      image = image,
      program = program,
      args = args,
    }
  end
end

--- Delete an app from the screen.
-- @tparam number screen Screen of the app.
-- @tparam number x X coordinate of the app.
-- @tparam number y Y coordinate of the app.
-- @treturn[1] table App details if the app was there.
-- @treturn[2] nil Nothing if there was no app there.
local function deleteApp(screen,x,y)
  local app = checkPosition(screen,x,y)
  local desktop = encfread("settings/desktop.dat")
  if app then
    desktop[screen][y][x] = nil
    desktop = encfwrite("settings/desktop.dat")
    return app
  end
end

--- Parse the desktop file and draw all the apps to the screen.
-- @tparam number screen Which screen to draw.
local function drawApps(screen)
  local desktop = encfread("settings/desktop.dat")
  local screen = desktop[screen]
  for i=1,#screen do
    local y = 3*(2*i-1)
    local _,_,linebg = term.current().getLine(y)
    for o=1,#screen[i] do
      local x = 2*(3*o-2)
      local app = screen[i][o]
      sUtils.asset.drawSkimg(app.image,o,i)
      local bg = linebg:sub(x,x+5)
      term.setCursorPos(x,y+5)
      term.blit(sUtils.cut(app.name,5),"00000",bg)
    end
  end
end

local function genTimeString()
  local offset
  if SkyOS and SkyOS.settings and SkyOS.settings.timezone then
    offset = SkyOS.settings.timezone
  else
    offset = 0
  end
  local epoch = math.floor(os.epoch("utc") / 1000) + (3600 * offset)
  local t = os.date("!*t",epoch)
  local time = {
    sec = t.sec,
    min = t.min,
    hour = t.hour,
    day = t.day,
    month = t.month,
    year = t.year,
  }
  for k,v in pairs(time) do
    local str = tostring(v)
    if str:len() == 1 then
      str = "0" .. str
    end
    time[k] = str
  end
  local filepath = "screenshots/" .. time.hour .. time.min .. time.sec .. "-" .. time.day .. time.month .. time.year .. ".skimg"
  return filepath
end

--- Screenshot the screen, and save it to `/screenshots/hhmmss-ddmmyyyy.skimg`
local function screenshot()
  if not term.current().getLine then
    -- We don't have screenshotting available, yikes.
    return
  end
  local x,y = term.getHeight()
  local data = {}
  for i=1,y do
    local text,fg,bg = term.current().getLine(i)
    data[i] = {text,fg,bg,i}
  end
  local creator = os.getComputerLabel() or "SkyOS"
  local attributes = {
    x=x,
    y=y,
    creator=creator,
    locked=false,
    type=1
  }
  local skimg = {attributes=attributes,data=data}
  local filepath = genTimeString()
  encfwrite(filepath,skimg)
end


return {
  downloadRepo = downloadRepo,
  updateSkyOS = updateSkyOS,
  screenshot = screenshot,
  --- Functions to interact with the desktop file.
  desktop = {
    checkPosition = checkPosition,
    addApp = addApp,
    editApp = editApp,
    deleteApp = deleteApp,
    drawApps = drawApps,
  }
}