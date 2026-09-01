import json
with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

keys_to_check = [
    "body.tracking.weekly_trend",
    "body.tracking.status.bulking.deficit.title",
    "body.tracking.no_target_measurement",
    "body.tracking.button.target",
    "common.new",
    "common.points.short",
    "body.timerange.sixm"
]

for key in keys_to_check:
    if key in data["strings"]:
        loc = data["strings"][key].get("localizations", {})
        if "zh-Hans" in loc:
            print(f"{key}: {loc['zh-Hans']['stringUnit']['value']}")
        else:
            print(f"{key}: MISSING")
