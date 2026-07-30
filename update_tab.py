import json

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

translations = {
    'de': 'Gewohnheiten',
    'en': 'Habits',
    'es': 'Hábitos',
    'fr': 'Habitudes',
    'hi': 'आदतें',
    'it': 'Abitudini',
    'ja': '習慣',
    'ko': '습관',
    'nl': 'Gewoonten',
    'pl': 'Nawyki',
    'pt': 'Hábitos',
    'ru': 'Привычки',
    'tr': 'Alışkanlıklar',
    'zh-Hans': '习惯',
    'zh-Hant': '習慣'
}

# Add tab.habits
data["strings"]["tab.habits"] = {
    "extractionState": "manual",
    "localizations": {}
}

for lang, text in translations.items():
    data["strings"]["tab.habits"]["localizations"][lang] = {
        "stringUnit": {
            "state": "translated",
            "value": text
        }
    }

# Remove tab.garten if it exists
if "tab.garten" in data["strings"]:
    del data["strings"]["tab.garten"]

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Updated Localizable.xcstrings")
