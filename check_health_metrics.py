import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

keys = [
    "health.metric.steps",
    "health.metric.water",
    "health.metric.sleep",
    "health.metric.mindfulness",
    "health.metric.running",
    "health.metric.strengthTraining",
    "apple.health.title",
    "plant.detail.custom_tracker.title"
]

for key in keys:
    if key in data["strings"]:
        print(f"Key {key} exists.")
        print(f"  ko: {data['strings'][key].get('localizations', {}).get('ko', {}).get('stringUnit', {}).get('value')}")
    else:
        print(f"Key {key} missing.")
