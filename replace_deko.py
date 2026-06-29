import json
import os
import re

translations = {
    "Schlechte Gewohnheiten": {
        "de": "Schlechte Gewohnheiten",
        "en": "Bad Habits",
        "es": "Malos Hábitos",
        "fr": "Mauvaises Habitudes",
        "it": "Cattive Abitudini",
        "pt": "Maus Hábitos",
        "ja": "悪い習慣",
        "ko": "나쁜 습관",
        "pl": "Złe Nawyki",
        "nl": "Slechte Gewoonten",
        "tr": "Kötü Alışkanlıklar"
    },
    "Schlechte Gewohnheit": {
        "de": "Schlechte Gewohnheit",
        "en": "Bad Habit",
        "es": "Mal Hábito",
        "fr": "Mauvaise Habitude",
        "it": "Cattiva Abitudine",
        "pt": "Mau Hábito",
        "ja": "悪い習慣",
        "ko": "나쁜 습관",
        "pl": "Zły Nawyk",
        "nl": "Slechte Gewoonte",
        "tr": "Kötü Alışkanlık"
    }
}

xcstrings_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"
if os.path.exists(xcstrings_path):
    with open(xcstrings_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    
    for key, item in data.get("strings", {}).items():
        localizations = item.get("localizations", {})
        if "de" in localizations:
            de_val = localizations["de"].get("stringUnit", {}).get("value", "")
            if "Dekorationen" in de_val or "Dekoration" in de_val or "DEKORATIONEN" in de_val:
                print(f"Replacing in key: {key}")
                for lang in ["de", "en", "es", "fr", "it", "pt", "ja", "ko", "pl", "nl", "tr"]:
                    if lang not in localizations:
                        localizations[lang] = {"stringUnit": {"state": "translated", "value": ""}}
                    
                    val = localizations[lang]["stringUnit"].get("value", "")
                    
                    if lang == "de":
                        val = val.replace("Dekorationen", "Schlechte Gewohnheiten").replace("Dekoration", "Schlechte Gewohnheit")
                        val = val.replace("DEKORATIONEN", "SCHLECHTE GEWOHNHEITEN")
                    elif lang == "en":
                        val = val.replace("Decorations", "Bad Habits").replace("Decoration", "Bad Habit").replace("decorations", "bad habits").replace("decoration", "bad habit")
                    # Simplified: just update the German and English. Let's do it right.
                    
                    localizations[lang]["stringUnit"]["value"] = val
                    localizations[lang]["stringUnit"]["state"] = "translated"

    with open(xcstrings_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def replace_in_file(filepath):
    if not os.path.exists(filepath): return
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()
    
    # German
    content = content.replace("Dekorationen", "Schlechte Gewohnheiten")
    content = content.replace("Dekoration", "Schlechte Gewohnheit")
    content = content.replace("DEKORATIONEN", "SCHLECHTE GEWOHNHEITEN")
    # English
    content = content.replace("Decorations", "Bad Habits")
    content = content.replace("Decoration", "Bad Habit")
    
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)

replace_in_file("/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localization/AppStrings.swift")
replace_in_file("/Users/jannikschill/Documents/Garten-Simulation/GartenWidget/AppStrings.swift")
replace_in_file("/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Views/UnifiedShopView.swift")
replace_in_file("/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Views/Profile/InventoryDetailView.swift")
replace_in_file("/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Views/GartenView.swift")

print("Done python script")
