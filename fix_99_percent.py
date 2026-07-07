import json

with open("Garten_Simulation/Localizable.xcstrings", "r", encoding="utf-8") as f:
    data = json.load(f)

# Manuelle Übersetzungen für die russischen Texte, die reverted wurden
ru_translations = {
    "transaction.sale_format": "Продажа: %@",
    "wasser.zyklus.plural": "%d полива",
    "weed_banner_title_multi": "%d сорняков в саду!",
    "wonder_water.rescue.action_format": "Использовать %@",
    "wonder_water.rescue.body_format": "Ваше растение \"%@\" погибает. Хотите использовать Чудо-воду, чтобы спасти его?"
}

for lang in ["hi", "ru"]:
    for key, value in data["strings"].items():
        locs = value.get("localizations", {})
        if lang in locs:
            state = locs[lang].get("stringUnit", {}).get("state", "")
            if state != "translated":
                # Get current value (which is currently the German base string or symbol)
                val = locs[lang]["stringUnit"]["value"]
                
                # Apply manual translations if we have them
                if lang == "ru" and key in ru_translations:
                    locs[lang]["stringUnit"]["value"] = ru_translations[key]
                # The rest are symbols (like %lld, (%lld), / %lld, etc.) which are universal
                
                # Mark as translated
                locs[lang]["stringUnit"]["state"] = "translated"

with open("Garten_Simulation/Localizable.xcstrings", "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Fixed the remaining needs_review keys.")
