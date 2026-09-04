import json
import os

patch_file = "scratch/batch2.json"
catalog_file = "Localizable.xcstrings"

if not os.path.exists(patch_file):
    print("Patch file not found")
    exit(1)

with open(patch_file, "r") as f:
    patches = json.load(f)

with open(catalog_file, "r") as f:
    catalog = json.load(f)

count = 0
for patch in patches:
    key = patch["key"]
    lang = patch["language"]
    translated = patch["translated_text"]
    
    if key in catalog["strings"]:
        if "localizations" not in catalog["strings"][key]:
            catalog["strings"][key]["localizations"] = {}
        if lang not in catalog["strings"][key]["localizations"]:
            catalog["strings"][key]["localizations"][lang] = {}
        
        catalog["strings"][key]["localizations"][lang]["stringUnit"] = {
            "state": "translated",
            "value": translated
        }
        count += 1
    else:
        print(f"Warning: Key {key} not found in catalog!")

with open(catalog_file, "w") as f:
    json.dump(catalog, f, indent=2, ensure_ascii=False)

print(f"Successfully applied {count} patches.")
