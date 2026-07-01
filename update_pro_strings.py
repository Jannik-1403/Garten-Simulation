import json

path = "Garten_Simulation/Localizable.xcstrings"

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

langs = ["de", "nl", "en", "fr", "it", "ja", "ko", "pl", "pt", "es", "tr"]

strings_to_add = {
    "paywall.title": ("Grovy Pro", "Grovy Pro"),
    "paywall.subtitle": ("Schalte das volle Potenzial deines Gartens frei.", "Unlock the full potential of your garden."),
    "paywall.feature.health.title": ("Apple Health Sync", "Apple Health Sync"),
    "paywall.feature.health.desc": ("Verknüpfe deine Schritte und Wasserziele direkt mit dem Garten.", "Link your steps and water goals directly to the garden."),
    "paywall.button.unlock": ("Jetzt Freischalten", "Unlock Now"),
    "paywall.description.lifetime": ("Einmalzahlung. Lifetime Zugriff.", "One-time payment. Lifetime access."),
    "paywall.loading": ("Lade Produkte...", "Loading Products..."),
    "paywall.button.debug": ("DEBUG: Pro Freischalten", "DEBUG: Unlock Pro"),

    "settings.pro.unlock": ("Grovy Pro freischalten", "Unlock Grovy Pro"),
    "settings.pro.subtitle": ("Erhalte vollen Zugriff", "Get full access"),
    "settings.section.integrations": ("Integrationen", "Integrations"),
    "settings.health.title": ("Apple Health", "Apple Health"),
    "settings.pro.badge": ("PRO", "PRO"),
    "settings.health.today": ("Heutige Health-Daten", "Today's Health Data"),
    "settings.health.steps": ("Schritte", "Steps"),
    "settings.health.water": ("Wasser", "Water")
}

for key, (de_val, en_val) in strings_to_add.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang in langs:
        if lang not in data["strings"][key]["localizations"]:
            val = en_val if lang == "en" else de_val
            data["strings"][key]["localizations"][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": val
                }
            }
        else:
            val = en_val if lang == "en" else de_val
            data["strings"][key]["localizations"][lang]["stringUnit"]["state"] = "translated"
            data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = val

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
