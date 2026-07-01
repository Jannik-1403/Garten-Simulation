import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

for key in ["common.cancel", "common.save", "common.delete"]:
    if key in data["strings"]:
        print(f"Key {key} exists. ko: {data['strings'][key].get('localizations', {}).get('ko', {}).get('stringUnit', {}).get('value')}")
    else:
        print(f"Key {key} missing.")
