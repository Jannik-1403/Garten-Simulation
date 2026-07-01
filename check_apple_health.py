import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

keys = [
    "apple.health.title",
    "settings.health.title",
    "paywall.feature.health.title"
]

for key in keys:
    if key in data["strings"]:
        ko_val = data["strings"][key].get('localizations', {}).get('ko', {}).get('stringUnit', {}).get('value')
        ja_val = data["strings"][key].get('localizations', {}).get('ja', {}).get('stringUnit', {}).get('value')
        print(f"Key {key}: ko='{ko_val}', ja='{ja_val}'")
    else:
        print(f"Key {key} missing.")
