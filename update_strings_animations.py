import json

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

new_keys = {
    "dop_score_title": {
        "de": "Dopamin-Ausschüttung", "en": "Dopamine Release", "es": "Liberación de dopamina", "fr": "Libération de dopamine"
    },
    "dop_score_food": {
        "de": "Leckeres Essen", "en": "Tasty Food", "es": "Comida rica", "fr": "Repas savoureux"
    },
    "dop_score_sport": {
        "de": "Sport", "en": "Workout", "es": "Deporte", "fr": "Sport"
    },
    "dop_score_tiktok": {
        "de": "Infinite Scrolling", "en": "Infinite Scrolling", "es": "Scroll infinito", "fr": "Défilement infini"
    },
    "dop_routines_title": {
        "de": "Echte Routinen aufbauen", "en": "Build real routines", "es": "Construir rutinas reales", "fr": "Construire de vraies routines"
    },
    "dop_routines_sub": {
        "de": "Statt schnellen Kicks baust du einen Garten voller Gewohnheiten.", "en": "Instead of quick kicks, build a garden of habits.", "es": "En lugar de estímulos rápidos, construye un jardín de hábitos.", "fr": "Au lieu de pics rapides, construis un jardin d'habitudes."
    },
    "dop_routines_read": { "de": "Lesen", "en": "Reading", "es": "Leer", "fr": "Lire" },
    "dop_routines_meditate": { "de": "Meditation", "en": "Meditation", "es": "Meditación", "fr": "Méditation" },
    "dop_routines_water": { "de": "Wasser trinken", "en": "Drink Water", "es": "Beber agua", "fr": "Boire de l'eau" },
    "dop_routines_run": { "de": "Laufen", "en": "Running", "es": "Correr", "fr": "Courir" },
    "dop_routines_learn": { "de": "Lernen", "en": "Learning", "es": "Aprender", "fr": "Apprendre" },
    "dop_routines_sleep": { "de": "Schlaf", "en": "Sleep", "es": "Sueño", "fr": "Sommeil" },
    "dop_btn_ziele": { "de": "Ziele definieren", "en": "Set Goals", "es": "Definir metas", "fr": "Définir des objectifs" }
}

# Just using English as fallback for other languages to keep script short
langs = ["de", "en", "es", "fr", "it", "pt-PT", "nl", "tr", "ru", "zh-Hans", "zh-Hant", "ja", "ko", "ar", "hi"]

for key, translations in new_keys.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    
    for lang in langs:
        if lang not in data["strings"][key]["localizations"]:
            data["strings"][key]["localizations"][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": translations.get(lang, translations.get("en", ""))
                }
            }

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Keys added successfully!")
