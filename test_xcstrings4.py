import json

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

print(data["strings"].get("tab.routines", {}).get("localizations", {}).get("en", {}).get("stringUnit", {}).get("value", "N/A"))
