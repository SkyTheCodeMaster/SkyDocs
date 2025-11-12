# Hash every item in indexed folders
# Runs through `src/` and hashes every lua file, placing it in `build/docs/lua/hashes.json`

print("-----START HASH.PY-----")

import hashlib
import json
import os

indexed_folders = ['src'] # This is recursive!
target_type = 'lua'

hash_files = []

print("Indexing folders...")

for file in indexed_folders:
  for root,dirs,files in os.walk(file,topdown=False):
    for name in files:
      if name[-len(target_type):] == target_type:
        print(f"queue: {os.path.join(root,name)}")
        hash_files.append(os.path.join(root,name))

hashes = {}

print("Hashing files...")

for file in hash_files:
  with open(file,"r",encoding="utf-8") as f:
    contents = f.read()
  try:
    hash = hashlib.sha256(contents.encode("utf-8","strict")).hexdigest()
    print(f"Hashed {file}, hash: {hash}")
    hashes[file] = hash
  except UnicodeDecodeError as e:
    print(f"Wops, no decodey {file} because {e}")

with open("build/docs/lua/hashes.json","w") as f:
  f.write(json.dumps(hashes,indent=2))

print("-----END HASH.PY-----")