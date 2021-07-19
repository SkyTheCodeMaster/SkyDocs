# Hash every item in indexed folders
# Runs through `src/` and hashes every lua file, placing it in `build/docs/lua/hashes.json`

print("-----START HASH.PY-----")

import os,hashlib,json

indexedFolders = ['src'] # This is recursive!
targetType = 'lua'

myFiles = []

print("Indexing folders...")

for x in indexedFolders:
  for root,dirs,files in os.walk(x,topdown=False):
    for name in files:
      if name[-len(targetType):] == targetType:
        print(f"queue: {os.path.join(root,name)}")
        myFiles.append(os.path.join(root,name))

hashes = {}

print("Hashing files...")

for x in myFiles:
  with open(x,"r",encoding="utf-8") as f:
    contents = f.read()
  try:
    hash = hashlib.sha256(contents.encode("utf-8","strict")).hexdigest()
    print(f"Hashed {x}, hash: {hash}")
    hashes[x] = hash
  except UnicodeDecodeError as e:
    print(f"Wops, no decodey {x} because {e}")

with open("build/docs/lua/hashes.json","w") as f:
  f.write(json.dumps(hashes,indent=2))

print("-----END HASH.PY-----")