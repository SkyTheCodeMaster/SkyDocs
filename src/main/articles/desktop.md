---
module: [kind=articles] SkyOS Desktop
---

The desktop for SkyOS is stored in `settings/desktop.dat`, which is a serialized table (`textutils.serialize()`), and it's data structure goes as follows:
```lua
{
  { -- This is the first desktop layout, or the home screen. Each screen is a table in this layer.
    { -- This is Y level 1.
      { -- This is X 1, which is `desktop[1][1]`
        name = "Shell", -- Text to display under the icon.
        type = "app" -- Whether or not this is an app or folder.
        image = "graphics/app/shell.skimg", -- Image of the icon, located in "graphics/app"
        program = "rom/programs/shell.lua", -- Program to open when this is clicked.
      },
      { -- This is X 2, which is `desktop[1][2]`
        name = "Other",
        type = "folder",
        contents = { -- This is where the contents of the folder are. Folders only support a 3x3 arrangement of programs.
          { -- Y level 1 of the folder.
            { -- X 1, `desktop[1][2].contents[1][1]
              name = "Shell", -- Text to display under the icon.
              type = "app" -- Whether or not this is an app or folder. Folders can only contain apps.
              image = "graphics/app/shell.skimg", -- Image of the icon, located in "graphics/app"
              program = "rom/programs/shell.lua", -- Program to open when this is clicked.
            }
          }
        }
      }
    }
  }
}
```
There will be a basic interface for this in the `sos` api.