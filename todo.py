#/usr/bin/python3
# Old todo command:
#grep -Rni todo src/ build/docs/lua/scripts build/docs/lua/scriptdata > build/docs/lua/todo.txt

import os
import sys

lArgs = sys.argv
sha = lArgs[1]
branch = lArgs[2]
print(str(lArgs))

myFiles = []
indexedFolders = ["src/","build/docs/lua/scripts","build/docs/lua/scriptdata"]

for x in indexedFolders:
  for root,dirs,files in os.walk(x,topdown=False):
    for name in files:
      myFiles.append(os.path.join(root,name))
    for name in dirs:
      myFiles.append(os.path.join(root,name))

for x in myFiles:
  print(x)
  
todo = []

def findTodo(file):
  with open(file) as f:
    for lineno, n in enumerate(f.lines()):
      if 'TODO' in n.upper():
        print("TODO Found!")