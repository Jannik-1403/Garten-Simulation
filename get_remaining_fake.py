import json

with open("fake_strings.json", "r") as f:
    fake_dict = json.load(f)

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

remaining = {}
for key, value in fake_dict.items():
    zh = data["strings"].get(key, {}).get("localizations", {}).get("zh-Hans", {}).get("stringUnit", {}).get("value", "")
    if zh == value:
        remaining[key] = value

print(json.dumps(remaining, indent=2, ensure_ascii=False))
print(f"Remaining fake strings: {len(remaining)}")
