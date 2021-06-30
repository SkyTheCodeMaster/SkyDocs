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

for root,dirs,files in os.walk(".",topdown=False):
  for name in files do:
    myFiles.append(os.path.join(root,name))
  for name in dirs do:
    myFiles.append(os.path.join(root,name))

newFiles = []

for x in myFiles:
  if 'git' in x:
    #print(f'Removing {x} from todo search')
  else:
    #print(f'Adding {x} to todo search')
    newFiles.append(x)

todo = []

def findTodo(file):
  with open(file) as f:
    for lineno, n in enumerate(f.lines()):
      if `TODO` in n.upper():
