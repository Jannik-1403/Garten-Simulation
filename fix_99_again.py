import json

with open("Garten_Simulation/Localizable.xcstrings", "r", encoding="utf-8") as f:
    data = json.load(f)

if "%lld %@ %lld %@" in data["strings"]:
    del data["strings"]["%lld %@ %lld %@"]
    print("Deleted unused %lld %@ %lld %@")

for key in ["screentime.tracker.confirm_msg", "screentime.tracker.confirm_title"]:
    if key in data["strings"]:
        locs = data["strings"][key].get("localizations", {})
        for lang, loc in locs.items():
            if "stringUnit" in loc:
                loc["stringUnit"]["state"] = "translated"

with open("Garten_Simulation/Localizable.xcstrings", "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Fixed translation states to 100%.")
