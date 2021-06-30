#/usr/bin/python3
# Old todo command:
#grep -Rni todo src/ build/docs/lua/scripts build/docs/lua/scriptdata > build/docs/lua/todo.txt

import os
import sys

lArgs = sys.argv
sha = lArgs[1]
print(str(lArgs))

myFiles = []
indexedFolders = ["src/","build/docs/lua/scripts","build/docs/lua/scriptdata"]

for x in indexedFolders:
  for root,dirs,files in os.walk(x,topdown=False):
    for name in files:
      myFiles.append(os.path.join(root,name))
    #for name in dirs:
    #  myFiles.append(os.path.join(root,name))

for x in myFiles:
  print(x)

todo = {}

def makeMDLink(todo,file,ln):
  return f"* [{file}:{ln}:{todo}](https://github.com/SkyTheCodeMaster/SkyDocs/blob/{sha}/{file}#L{ln})\n"

def findTodo(file):
  with open(file) as f:
    try:
      for lineno, n in enumerate(f):
        if 'TODO' in n.upper():
          print(f"TODO found in {file} at line number {lineno}. Contents: {n}")
          todo.append(makeMDLink(n,file,lineno+1))
    except UnicodeDecodeError:
      pass # pass lol just don't add it if we can't decode it. ez pz lemon squeezy pcall when please?
      
for x in myFiles:

  findTodo(x)

mdDoc = f"""---
module: [kind=articles] To-Do
---
List of TODO: lines in {indexedFolders}:
"""

for x in todo:
  mdDoc += x

with open("src/main/articles/todo.md","w") as f:
  f.write(mdDoc)