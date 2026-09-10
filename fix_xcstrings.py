import json

file_path = "Garten_Simulation/Localizable.xcstrings"

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

# 1. Delete key "1"
if "strings" in data and "1" in data["strings"]:
    del data["strings"]["1"]
    print("Deleted key '1'")

# 2. Delete pt-PT (Portuguese Portugal) entirely
if "strings" in data:
    for key, value in data["strings"].items():
        if "localizations" in value and "pt-PT" in value["localizations"]:
            del value["localizations"]["pt-PT"]
    print("Deleted 'pt-PT' from all strings")
    
# Remove pt-PT from metadata if it exists there (it shouldn't, but just in case)

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
