; -*- mode: Lisp;-*-

(sources
  /src/main/create/
  /src/main/skyos/
  /src/main/misc/
  /src/main/articles/
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
    (head doc/head.html))

  (module-kinds
    (skyos SkyOS)
    (misc Misc)
    (create Create)
    (wip WIP)
    (articles Articles))

  (library-path
    /src/main/create/
    /src/main/skyos/
    /src/main/misc/
    /src/main/articles))

(at /
  (linters
    syntax:string-index)
  (lint
    (bracket-spaces
      (call no-space)
      (function-args no-space)
      (parens no-space)
      (table space)
      (index no-space))

    (globals
      :max
      _CC_DEFAULT_SETTINGS
      _CC_DISABLE_LUA51_FEATURES
      ;; Ideally we'd pick these up from bios.lua, but illuaminate currently
      ;; isn't smart enough.
      sleep write printError read rs)))