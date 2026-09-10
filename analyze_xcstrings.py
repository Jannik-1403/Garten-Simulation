import json

file_path = "Garten_Simulation/Localizable.xcstrings"

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

source_language = data.get("sourceLanguage", "en")
strings = data.get("strings", {})

missing_translations = {}
languages_seen = set()

# First pass: collect all languages
for key, value in strings.items():
    if "localizations" in value:
        languages_seen.update(value["localizations"].keys())

for key, value in strings.items():
    if key == "1":
        continue
    
    localizations = value.get("localizations", {})
    
    for lang in languages_seen:
        if lang == source_language:
            continue
        
        needs_translation = False
        if lang not in localizations:
            needs_translation = True
        else:
            loc = localizations[lang]
            if "stringUnit" in loc and loc["stringUnit"].get("state") != "translated":
                needs_translation = True
        
        if needs_translation:
            if lang not in missing_translations:
                missing_translations[lang] = []
            missing_translations[lang].append(key)

print(json.dumps(missing_translations, indent=2, ensure_ascii=False))
