import json

translations = {
    "de": "Habits",
    "en": "Habits",
    "es": "Hábitos",
    "fr": "Habitudes",
    "hi": "आदतें",
    "it": "Abitudini",
    "ja": "習慣",
    "ko": "습관",
    "nl": "Gewoonten",
    "pl": "Nawyki",
    "pt": "Hábitos",
    "ru": "Привычки",
    "tr": "Alışkanlıklar",
    "zh-Hans": "习惯",
    "zh-Hant": "習慣"
}

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

# Find all languages in the project from existing keys
all_langs = set()
for k, v in data.get("strings", {}).items():
    locs = v.get("localizations", {})
    all_langs.update(locs.keys())

key = "tab.habits"
if key not in data["strings"]:
    data["strings"][key] = {
        "extractionState": "manual",
        "localizations": {}
    }

for lang in all_langs:
    val = translations.get(lang, "Habits")
    data["strings"][key]["localizations"][lang] = {
        "stringUnit": {
            "state": "translated",
            "value": val
        }
    }

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

