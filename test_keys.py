import json
file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

for key, value in data.get("strings", {}).items():
    if "low" in key.lower():
        locs = value.get("localizations", {})
        print(f"--- {key} ---")
        for lang, loc_data in locs.items():
            if "stringUnit" in loc_data:
                val = loc_data['stringUnit'].get('value')
                if val == "Low":
                    print(f"  {lang}: {val}")
