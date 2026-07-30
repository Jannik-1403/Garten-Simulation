import json

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

for key, value in data.get("strings", {}).items():
    if key.startswith("tab."):
        locs = value.get("localizations", {})
        de_text = locs.get("de", {}).get("stringUnit", {}).get("value", "N/A")
        print(f"Key: {key}, DE: {de_text}")
