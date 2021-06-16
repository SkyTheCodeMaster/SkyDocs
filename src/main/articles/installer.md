---
module: [kind=articles] Installer
---

The installer script (Accessable under `https://skydocs.madefor.cc/scripts/installer.lua`) takes a JSON file, online, or locally stored and installs files from it, according to it's location.  
The structure of the JSON file should look like this:  
```json
{
  "url": {
    "path": "filepath",
    "folder": true,
    "recursive": false
  }
}
```  
URLs to the file or folder are stored as the keys of each new table, and inside the table are two or three elements, depending on if it's a folder or not.  
The first element, present in all types is `path`, which is where files will be saved to. This must be a string.  
The second element, present in all types is `folder`, which is a boolean on whether or not the url is a folder link.  
If a url is a folder link, it *must* be a *Github* folder link, in the style of `https://github.com/user/repo/tree/branch/folder`, eg. `https://github.com/SkyTheCodeMaster/SkyOS/tree/master/graphics`. This supports subfolders, for example `https://github.com/SkyTheCodeMaster/SkyOS/tree/master/graphics/background`.  
The third element, only present in folders, is the `recursive` element. If this is true, it would download folders inside of the target folder, and so on, so for example:  
```json
{
  "https://github.com/SkyTheCodeMaster/SkyOS/tree/master/graphics": {
    "path": "graphics",
    "folder": true,
    "recursive": true
  }
}
```  
This will download everything in `SkyOS/graphics`, which includes the subfolder `background`, so this would download, for example:
`graphics/taskbar.skimg`  
`graphics/bootSplash.skimg`  
`graphics/background/default.skimg`  

You can call the script with `wget run https://skydocs.madefor.cc/scripts/installer.lua`, and it's singular argument is a location for the requirements JSON file.
For example: `wget run https://skydocs.madefor.cc/scripts/installer.lua https://raw.githubusercontent.com/SkyTheCodeMaster/SkyOS/master/requirements.json`.