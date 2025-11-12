# Runs through `src/` and minifies every lua file, dumping it into `build/docs/lua/minified/<name>.lua`

print("-----START MINIFY.PY-----")

import os
import subprocess
import humanize

indexed_folders = ['src'] # This is recursive!
target_file_type = 'lua'

minified_files = []

print("Indexing folders...")

for file in indexed_folders:
  for root,dirs,files in os.walk(file,topdown=False):
    for name in files:
      if name[-len(target_file_type):] == target_file_type:
        print(f"queue: {os.path.join(root,name)}")
        minified_files.append({'path':os.path.join(root,name),'name':name})

print("Minifying and writing to `build/docs/lua/minified/`")

for file in minified_files:
  print(f"minify: {file['name']}")
  subprocess.run(f"bin/illuaminate minify {file['path']} > build/docs/lua/minified/{file['name']}",shell=True)

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

for file in minified_files:
  # Find the original and minified size of the libraries.
  with open(file["path"], "r") as f:
    original_size = len(f.read())
  with open(f"build/docs/lua/minified/{file['name']}", "r") as f:
    minified_size = len(f.read())
  html += f'      <li><a href="https://skydocs.madefor.cc/minified/{file["name"]}">{file["name"]}</a> (min: {humanize.naturalsize(minified_size)}, orig: {humanize.naturalsize(original_size)})</li>\n'

html += """    </ul>
  </body>
</html>"""

with open("build/docs/lua/minified/index.html","w") as f:
  f.write(html)

print("-----END MINIFY.PY-----")