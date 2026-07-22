import json
import os
import sys
from deep_translator import GoogleTranslator

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

# Hardcoded english bases for these strings since they are completely missing
base_strings = {
    "routine.strict_mode.blocked.message": "You cannot exit strict mode until the routine is complete.",
    "routine.strict_mode.blocked.ok": "OK",
    "routine.strict_mode.blocked.title": "Strict Mode Active",
    "routine.strict_mode.prompt.title": "Enable Strict Mode?",
    "focus.strict_mode.prompt.title": "Enable Strict Mode?",
    "common.yes": "Yes",
    "common.no": "No",
    "focus.live_activity.tasks": "Tasks"
}

lang_mapping = {
    'en': 'en', 'es': 'es', 'fr': 'fr', 'hi': 'hi', 'it': 'it',
    'ja': 'ja', 'ko': 'ko', 'nl': 'nl', 'pl': 'pl', 'pt': 'pt',
    'pt-BR': 'pt', 'ru': 'ru', 'tr': 'tr', 'zh-Hans': 'zh-CN',
    'zh-Hant': 'zh-TW', 'de': 'de'
}

all_langs = set(lang_mapping.keys())

for key in base_strings:
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    locs = data["strings"][key].get("localizations", {})
    base_text = base_strings[key]
    
    for l in all_langs:
        # Check if already translated
        if l in locs and locs[l].get("stringUnit", {}).get("state") == "translated":
            continue
            
        print(f"Translating '{key}' to {l}...")
        try:
            target = lang_mapping[l]
            if l == "en":
                translation = base_text
            else:
                translation = GoogleTranslator(source='en', target=target).translate(base_text)
                
            locs[l] = {
                "stringUnit": {
                    "state": "translated",
                    "value": translation
                }
            }
        except Exception as e:
            print(f"Error translating to {l}: {e}")
            
    data["strings"][key]["localizations"] = locs

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
    
print("Done filling missing translations.")
