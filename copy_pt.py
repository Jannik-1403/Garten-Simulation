import json

path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

count = 0
for key, item in data.get("strings", {}).items():
    locs = item.get("localizations", {})
    if "pt-BR" in locs and "pt" not in locs:
        locs["pt"] = locs["pt-BR"].copy()
        count += 1
        
    # Also fix strength details just in case
    # Let's ensure strength details have the right translations for the 16 languages

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Copied pt-BR to pt for {count} keys.")
