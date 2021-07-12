# Runs through `src/` and minifies every lua file, dumping it into `build/docs/lua/minified/<name>.lua`

print("-----START MINIFY.PY-----")

import os,subprocess,sys

indexedFolders = ['src'] # This is recursive!
targetType = 'lua'

myFiles = []

print("Indexing folders...")

for x in indexedFolders:
  for root,dirs,files in os.walk(x,topdown=False):
    for name in files:
      if name[-len(targetType):] == targetType:
        print(f"queue: {os.path.join(root,name)}")
        myFiles.append({'path':os.path.join(root,name),'name':name})

print("Minifying and writing to `build/docs/lua/minified/`")

for x in myFiles:
  print(f"minify: {x['name']}")
  subprocess.run(f"bin/illuaminate minify {x['path']} > build/docs/lua/minified/{x['name']}",shell=True)

print("-----END MINIFY.PY-----")