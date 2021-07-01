; -*- mode: Lisp;-*-

(sources
  /src/main/create/
  /src/main/skyos/
  /src/main/misc/
  /src/main/articles/
  /src/main/skyos-events/
  /src/main/skyos-callbacks/
)


(doc
  (destination build/docs/lua)
  (index doc/index.md)

  (site
    (title "SkyDocs")
    (logo src/main/pack.png)
    (url https://skydocs.madefor.cc/)
    (source-link https://github.com/SkyTheCodeMaster/SkyDocs/blob/${commit}/${path}#L${line})

    (styles src/web/styles.css)
    ;;(scripts build/rollup/index.js)
    (head doc/head.html)
  )

  (module-kinds
    (skyos SkyOS)
    (misc Misc)
    (create Create)
    (wip WIP)
    (articles Articles)
    (skyosevent "SkyOS Events")
    (skyoscallback "SkyOS Callbacks")
  )

  (library-path
    /src/main/create/
    /src/main/skyos/
    /src/main/misc/
    /src/main/articles/
    /src/main/skyos-events/
    /src/main/skyos-callbacks/
  )
)

(at /
  (linters
    -syntax:string-index
    -format:separator-space
    -format:bracket-space
  )
  (lint
    (bracket-spaces
      (call no-space)
      (function-args no-space)
      (parens no-space)
      (table space)
      (index no-space)
    )

    (globals
      :max
      _CC_DEFAULT_SETTINGS
      _CC_DISABLE_LUA51_FEATURES
      sleep 
      write 
      printError 
      read 
      rs 
      SkyOS
      colors
      colours
      commands
      disk
      fs
      gps
      help
      http
      io
      keys
      multishell
      os 
      paintutils
      parallel
      peripheral
      pocket
      rednet
      redstone
      settings 
      shell
      term
      textutils
      turtle
      vector
      window
      _HOST
    )
  )
)