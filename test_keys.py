import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

test_keys = [
    "custom.tracker.title",
    "custom.tracker.create.button",
    "custom.tracker.create.title",
    "custom.tracker.create.message",
    "custom.tracker.name.placeholder",
    "custom.tracker.delete.title",
    "custom.tracker.delete.message",
    "custom.tracker.target",
    "custom.tracker.progress.today",
    "health.metric.mindfulness",
    "common.delete",
    "common.save"
]

for key in test_keys:
    if key in data["strings"]:
        ko_val = data["strings"][key].get('localizations', {}).get('ko', {}).get('stringUnit', {}).get('value')
        print(f"{key}: {ko_val}")
    else:
        print(f"MISSING: {key}")
