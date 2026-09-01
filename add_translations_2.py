import json
import os
from deep_translator import GoogleTranslator

# The languages supported in Garten_Simulation
TARGET_LANGS = [
    "en", "es", "fr", "hi", "it", "ja", "ko", "nl", 
    "pl", "pt-BR", "ru", "tr", "zh-Hans", "zh-Hant"
]

strings_to_add = {
    "calorie.calc.title": "Dein Kalorienbedarf",
    "calorie.calc.desc.success": "Dieser Wert (TDEE) wird basierend auf der Mifflin-St. Jeor Formel und deinen Körperdaten berechnet.",
    "calorie.calc.desc.missing": "Es fehlen Körperdaten, um deinen genauen Kalorienbedarf zu berechnen. Bitte ergänze sie unten.",
    "calorie.calc.weight": "Gewicht",
    "calorie.calc.height": "Körpergröße",
    "calorie.calc.age": "Alter",
    "calorie.calc.years": "Jahre",
    "calorie.calc.sex": "Geschlecht",
    "sex.female": "Weiblich",
    "sex.male": "Männlich",
    "sex.none": "Auswählen",
    "calorie.calc.nav": "Daten & Kalorien",
    "calorie.calc.tap_for_details": "Berechnung ansehen",
    "macro.recommendation.missing.new": "Es fehlen einige Körperdaten, um dir eine genaue Empfehlung zu geben. Bitte ergänze sie in der Übersicht.",
    "health.metric.calories": "Kalorien"
}

file_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

def translate(text, target):
    if target == "zh-Hans":
        t = "zh-CN"
    elif target == "zh-Hant":
        t = "zh-TW"
    elif target == "pt-BR":
        t = "pt"
    else:
        t = target
        
    try:
        translated = GoogleTranslator(source='de', target=t).translate(text)
        return translated
    except Exception as e:
        print(f"Error translating {text} to {target}: {e}")
        return text

for key, de_text in strings_to_add.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {
                "de": {
                    "stringUnit": {
                        "state": "translated",
                        "value": de_text
                    }
                }
            }
        }
    
    # Translate to all other languages
    for lang in TARGET_LANGS:
        if lang not in data["strings"][key]["localizations"]:
            print(f"Translating {key} to {lang}...")
            trans_text = translate(de_text, lang)
            data["strings"][key]["localizations"][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": trans_text
                }
            }

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Translations added successfully.")
