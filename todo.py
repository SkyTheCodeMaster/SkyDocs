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

def makeFileLink(file,ln):
  return f"https://github.com/SkyTheCodeMaster/SkyDocs/blob/{sha}/{file}#L{ln}"

def findTodo(file):
  with open(file) as f:
    for lineno, n in enumerate(f.lines()):
      if 'TODO' in n.upper():
        print(f"TODO found in {file} at line number {lineno}. Contents: {n}")
        todo[n] = makeFileLink(file,lineno)
      
for x in myFiles:
  findTodo(x)

mdDoc = f"""---
module: [kind=articles] To-Do
---
List of TODO: lines in {indexedFolders}:
"""

for k,v in todo.items():
  mdDoc += f"* [{k}]({v})\n"

with open("src/main/articles/todo.md","w") as f:
  f.write(mdDoc)