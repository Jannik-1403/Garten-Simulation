import json

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

strings = data.get("strings", {})
languages = ["en", "es", "fr", "hi", "it", "ja", "ko", "nl", "pl", "pt", "pt-BR", "ru", "tr", "zh-Hans", "zh-Hant"]

missing = {lang: [] for lang in languages}
missing_total = 0

for key, entry in strings.items():
    localizations = entry.get("localizations", {})
    for lang in languages:
        lang_entry = localizations.get(lang, {})
        state = lang_entry.get("stringUnit", {}).get("state")
        if state != "translated":
            missing[lang].append(key)
            missing_total += 1

print(f"Total missing or untranslated entries across all languages: {missing_total}")
for lang in languages:
    if missing[lang]:
        print(f"[{lang}] Missing {len(missing[lang])} translations. First 5 keys:")
        for k in missing[lang][:5]:
            print(f"  - {k}")
