import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

keys = [
    "export.selection.title",
    "export.selection.only_this",
    "export.selection.all",
    "pdf.notes.good_habits",
    "pdf.notes.bad_habits",
    "export.selection.generate",
    "button.cancel"
]

for key in keys:
    if key in data["strings"]:
        ko_val = data["strings"][key].get('localizations', {}).get('ko', {}).get('stringUnit', {}).get('value')
        print(f"Key {key} exists. ko: {ko_val}")
    else:
        print(f"Key {key} missing.")
