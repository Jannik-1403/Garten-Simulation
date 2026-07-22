import json

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

stale_keys = []
for key, item in data["strings"].items():
    if item.get("extractionState") == "stale":
        stale_keys.append(key)

print("Found stale keys:", stale_keys)

for key in stale_keys:
    del data["strings"][key]

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")

print("Deleted", len(stale_keys), "stale keys.")
