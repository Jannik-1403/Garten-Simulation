import json
with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

for key, value in data["strings"].items():
    loc = value.get("localizations", {})
    if "zh-Hans" not in loc or loc["zh-Hans"].get("stringUnit", {}).get("state") != "translated":
        print("Missing in zh-Hans:", key)
