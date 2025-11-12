#/usr/bin/python3
# Old todo command:
#grep -Rni todo src/ build/docs/lua/scripts build/docs/lua/scriptdata > build/docs/lua/todo.txt

print("-----START TODO.PY-----")

import os
import sys

args = sys.argv
sha = args[1]

files = []
indexed_folders = ["src/","build/docs/lua/scripts","build/docs/lua/scriptdata"]

for folder in indexed_folders:
  for root,dirs,files in os.walk(folder,topdown=False):
    for name in files:
      files.append(os.path.join(root,name))

todo = []

def make_md_link(todo,file,ln):
  return f"* [{file}:{ln}:{todo}](https://github.com/SkyTheCodeMaster/SkyDocs/blob/{sha}/{file}#L{ln})\n"

def find_todos(file):
  with open(file) as f:
    try:
      for lineno, n in enumerate(f):
        if 'TODO' in n.upper():
          print(f"TODO found in {file} at line number {lineno}. Contents: {n}")
          todo.append(make_md_link(n,file,lineno+1))
    except UnicodeDecodeError:
      pass # If the file can't be decoded, skip it.
      
for folder in files:
  find_todos(folder)

index_string = ""
for i,v in enumerate(indexed_folders):
  if int(i) == (len(indexed_folders)-1):
    index_string += f" and `{v}`"
  else:
    index_string += f"`{v}`, "


markdown_document = f"""---
module: [kind=articles] To-Do
---
List of TODO: lines in {index_string}:
"""

for folder in todo:
  markdown_document += folder

with open("src/main/articles/todo.md","w") as f:
  f.write(markdown_document)

print("-----END TODO.PY-----")