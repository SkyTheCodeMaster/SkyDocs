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

html = """<html>
  <head>
    <title>Minified APIs</title>
    <meta property="og:title" content="Minified APIs">
    <meta property="og:type" content="website">
    <meta property="og:url" content="https://skydocs.madefor.cc/minified/">
    <meta property="og:description" content="All of the APIs on SkyDocs, but in a minified format.">
    <meta name=theme-color" content="#57A64E">
  </head>
  <body>
    <h1>Minified APIs</h1>
    <p>These are all the various APIs stored on SkyDocs, but in a minified format, for compact systems.</p>
    <ul>
"""

for x in myFiles:
  html += f'      <li><a href="https://skydocs.madefor.cc/minified/{x["name"]}">{x["name"]}</a></li>\n'

html += """    </ul>
  </body>
</html>"""

with open("build/docs/lua/minified/index.html","w") as f:
  f.write(html)

print("-----END MINIFY.PY-----")