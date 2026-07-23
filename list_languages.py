import json

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

languages = set()
for v in data["strings"].values():
    if "localizations" in v:
        for lang in v["localizations"].keys():
            languages.add(lang)

print("Languages:", ", ".join(sorted(languages)))
