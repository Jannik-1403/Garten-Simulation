import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

test_keys = [
    "custom.tracker.title",
    "custom.tracker.create",
    "custom.tracker.target",
    "custom.tracker.progress",
    "custom.tracker.create.title",
    "custom.tracker.name.placeholder",
    "custom.tracker.create.message",
    "custom.tracker.delete.title",
    "custom.tracker.delete.message",
    "common.cancel",
    "common.save",
    "common.delete",
    "apple.health.progress",
    "apple.health.target",
    "apple.health.unit.steps",
    "apple.health.unit.water",
    "apple.health.unit.sleep",
    "apple.health.unit.mindfulness",
    "apple.health.unit.running",
    "apple.health.unit.strengthTraining",
    "apple.health.pro_locked",
    "plant.detail.notes_header"
]

for key in test_keys:
    if key in data["strings"]:
        ko_val = data["strings"][key].get('localizations', {}).get('ko', {}).get('stringUnit', {}).get('value')
        print(f"Key {key} exists. ko: {ko_val}")
    else:
        print(f"Key {key} missing.")
