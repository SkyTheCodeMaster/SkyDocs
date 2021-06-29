---
module: [kind=articles] SkyOS Desktop
---

The desktop for SkyOS is stored in `settings/desktop.dat`, which is a serialized table (`textutils.serialize()`), and it's data structure goes as follows:
```
{
  { -- This is the first desktop layout, or the home screen. Each screen is a table in this layer.
    { -- This is Y level 1.
      { -- This is X 1, which is Homescreen/1/1. (First screen, Y 1, X 1)
        name = "Shell", -- Text to display under the icon.
        image = "graphics/app/shell.skimg", -- Image of the icon, located in "graphics/app"
        program = "rom/programs/shell.lua", -- Program to open when this is clicked.
      },
      { -- This is X 2, which is Homescreen/1/2. (First screen, Y 1, X 1)
        name = " GPS ",
        image = "graphics/app/gps.skimg",
        program = "user/programs/gps.lua", -- "user/programs" is where user programs are stored.
        args = "host", -- Different locations can have different arguments.
      }
    }
  }
  { -- This is the second screen, which can be access by swiping to the right, while not clicking on a program.
    { -- Y level 1
      { -- X 1
        { -- Duplicate apps are allowed.
          name = " GPS ",
          image = "graphics/app/gps.skimg",
          program = "user/programs/gps.lua",
          args = "locate", -- Different locations can have different arguments.
        }
      }
    }
  }
}
```
There will be a basic interface for this in the `sos` api.