import json
import sys
import time
from deep_translator import GoogleTranslator

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

lang_map = {
    "en": "en",
    "es": "es",
    "fr": "fr",
    "hi": "hi",
    "it": "it",
    "ja": "ja",
    "ko": "ko",
    "nl": "nl",
    "pl": "pl",
    "pt": "pt",
    "ru": "ru",
    "tr": "tr",
    "zh-Hans": "zh-CN",
    "zh-Hant": "zh-TW"
}

german_fallbacks = {
    "onboarding.screentime.settings": "Zu den Einstellungen",
    "common.cancel": "Abbrechen",
    "onboarding.screentime.error": "iOS hat die Berechtigung verweigert. Fehlermeldung: %@.\n\nBitte überprüfe deine Berechtigungen in den Einstellungen.",
    "onboarding.screentime.error.title": "Berechtigung fehlgeschlagen",
    "settings.restore.success_message": "Deine alten Daten wurden wiederhergestellt. Die App wird nun beendet. Bitte starte sie neu, um die Änderungen zu sehen.",
    "common.points.short": "Pkt",
    "common.free.parentheses": "(Gratis)",
    "apple.health.link": "Mit Apple Health verbinden",
    "apple.health.unlink": "Apple Health trennen",
    "apple.health.unlink.confirm.message": "Möchtest du die Verbindung zu Apple Health wirklich trennen?",
    "apple.health.unlink.confirm.title": "Verbindung trennen",
    "apple.health.unlinked_message": "Apple Health wurde erfolgreich getrennt.",
    "onboarding_ziel_placeholder": "Mein Ziel...",
    "routine.todo.default": "Neue Aufgabe",
    "routine.todo.description": "Beschreibung",
    "routine.todo.description.placeholder": "Details zur Aufgabe...",
    "weekly_report.chart.habits.value": "%lld Gewohnheiten"
}

strings = data.setdefault("strings", {})

# Add our newly created keys from Swift replacement
for new_key in german_fallbacks.keys():
    if new_key not in strings:
        strings[new_key] = {"localizations": {}}

translated_count = 0

for key, value in strings.items():
    localizations = value.setdefault("localizations", {})
    
    # Determine the German source
    de_val = key
    if "de" in localizations and localizations["de"].get("stringUnit", {}).get("value"):
        de_val = localizations["de"]["stringUnit"]["value"]
    elif key in german_fallbacks:
        de_val = german_fallbacks[key]
    
    # Provide DE if not there
    if "de" not in localizations or localizations["de"].get("stringUnit", {}).get("state") != "translated":
        localizations["de"] = {
            "stringUnit": {
                "state": "translated",
                "value": de_val
            }
        }
    
    for lang_code, trans_code in lang_map.items():
        state = localizations.get(lang_code, {}).get("stringUnit", {}).get("state")
        
        # We also want to translate if it's missing completely
        if state != "translated" or lang_code not in localizations:
            if not de_val.strip():
                # Empty string case
                translated = de_val
            else:
                try:
                    translated = GoogleTranslator(source='de', target=trans_code).translate(de_val)
                    # Simple fix for percent signs
                    translated = translated.replace("％", "%").replace("%%", "%")
                    # We shouldn't use %% according to user rules
                    time.sleep(0.2)
                except Exception as e:
                    print("Error translating:", de_val, "to", trans_code, e)
                    translated = de_val
            
            localizations[lang_code] = {
                "stringUnit": {
                    "state": "translated",
                    "value": translated
                }
            }
            translated_count += 1

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"Translation completed and saved. Translated {translated_count} missing values.")
