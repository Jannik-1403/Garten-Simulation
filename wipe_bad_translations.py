import json

keys_to_wipe = [
    "screentime.tracker.confirm_msg",
    "screentime.tracker.confirm_title",
    "screentime.tracker.settings",
    "screenTime.blocked.title",
    "screenTime.blocked.desc",
    "screenTime.auth.request",
    "screenTime.schedule.active",
    "screenTime.schedule.start",
    "screenTime.schedule.end",
    "screenTime.schedule.select_apps",
    "screenTime.info.title",
    "screenTime.info.desc",
    "screenTime.title",
    "screentime.tracker.no_live"
]

with open("Garten_Simulation/Localizable.xcstrings", "r", encoding="utf-8") as f:
    data = json.load(f)

for key in keys_to_wipe:
    if key in data["strings"]:
        locs = data["strings"][key].get("localizations", {})
        langs = list(locs.keys())
        for lang in langs:
            if lang != "de":
                del locs[lang]

with open("Garten_Simulation/Localizable.xcstrings", "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Wiped non-DE translations for screen time keys.")
