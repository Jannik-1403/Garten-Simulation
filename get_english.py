import json

keys = [
    "%lldh %lldm",
    "bad_habit.screen_time.desc",
    "bad_habit.screen_time.name",
    "common.hours",
    "common.hours.short",
    "common.minutes",
    "common.minutes.short",
    "habit.screen_time.desc",
    "habit.screen_time.name",
    "note.auto.screentime_success",
    "screentime.preprompt.button",
    "screentime.preprompt.desc",
    "screentime.preprompt.subtitle",
    "screentime.preprompt.title",
    "screenTime.reason.exceeded",
    "screenTime.target.label",
    "settings.screenTime.instruction"
]

with open("Garten_Simulation/Localizable.xcstrings", "r", encoding="utf-8") as f:
    data = json.load(f)

for key in keys:
    if key in data["strings"]:
        locs = data["strings"][key].get("localizations", {})
        if "en" in locs:
            print(f"{key}: {locs['en'].get('stringUnit', {}).get('value')}")
