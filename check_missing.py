import json

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

source_language = data.get("sourceLanguage", "de")
print(f"Source Language: {source_language}")

target_langs = set()
for key, value in data["strings"].items():
    if "localizations" in value:
        target_langs.update(value["localizations"].keys())

print(f"Target Languages found: {target_langs}")
print(f"Total Languages: {len(target_langs)}")

missing_count = 0
missing_dict = {}

for key, value in data["strings"].items():
    localizations = value.get("localizations", {})
    
    for lang in target_langs:
        if lang == source_language:
            continue
            
        loc = localizations.get(lang, {})
        state = loc.get("stringUnit", {}).get("state", "new")
        if state != "translated":
            if lang not in missing_dict:
                missing_dict[lang] = []
            missing_dict[lang].append(key)
            missing_count += 1

print(f"\nTotal missing translations: {missing_count}")
for lang, keys in missing_dict.items():
    print(f"  {lang}: {len(keys)} missing")
    print(f"    Examples: {keys[:3]}")

with open("needs_translation.json", "w", encoding="utf-8") as f:
    json.dump(missing_dict, f, indent=2, ensure_ascii=False)
