
import os

langs = ["de", "en", "es", "fr", "it", "pt"]
new_keys = {
    "de": [
        "intent_water_title = \"Pflanze gießen\";",
        "intent_water_desc = \"Gieße eine deiner Pflanzen.\";",
        "shortcut_gießen_titel = \"Pflanze gießen\";",
        "intent_water_already_done = \"%@ wurde heute schon gegossen.\";",
        "intent_water_success = \"%@ wurde erfolgreich gegossen! Dein Streak wurde erhöht.\";",
        "intent_water_fail = \"Pflanze nicht gefunden.\";"
    ],
    "en": [
        "intent_water_title = \"Water plant\";",
        "intent_water_desc = \"Water one of your plants.\";",
        "shortcut_gießen_titel = \"Water plant\";",
        "intent_water_already_done = \"%@ has already been watered today.\";",
        "intent_water_success = \"%@ was successfully watered! Your streak has increased.\";",
        "intent_water_fail = \"Plant not found.\";"
    ],
    "es": [
        "intent_water_title = \"Regar planta\";",
        "intent_water_desc = \"Riega una de tus plantas.\";",
        "shortcut_gießen_titel = \"Regar planta\";",
        "intent_water_already_done = \"%@ ya ha sido regado hoy.\";",
        "intent_water_success = \"¡%@ ha sido regado con éxito! Tu racha ha aumentado.\";",
        "intent_water_fail = \"Planta no encontrada.\";"
    ],
    "fr": [
        "intent_water_title = \"Arroser la plante\";",
        "intent_water_desc = \"Arrose l'une de tes plantes.\";",
        "shortcut_gießen_titel = \"Arroser la plante\";",
        "intent_water_already_done = \"%@ a déjà été arrosé aujourd'hui.\";",
        "intent_water_success = \"%@ a été arrosé avec succès ! Ton streak a augmenté.\";",
        "intent_water_fail = \"Plante non trouvée.\";"
    ],
    "it": [
        "intent_water_title = \"Annaffia pianta\";",
        "intent_water_desc = \"Annaffia una delle tue piante.\";",
        "shortcut_gießen_titel = \"Annaffia pianta\";",
        "intent_water_already_done = \"%@ è già stata annaffiata oggi.\";",
        "intent_water_success = \"%@ è stata annaffiata con successo! La tua serie è aumentata.\";",
        "intent_water_fail = \"Pianta non trovata.\";"
    ],
    "pt": [
        "intent_water_title = \"Regar planta\";",
        "intent_water_desc = \"Rega uma das tuas plantas.\";",
        "shortcut_gießen_titel = \"Regar planta\";",
        "intent_water_already_done = \"%@ já foi regada hoje.\";",
        "intent_water_success = \"%@ foi regada com sucesso! O teu streak aumentou.\";",
        "intent_water_fail = \"Planta não encontrada.\";"
    ]
}

for lang in langs:
    path = f"/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/{lang}.lproj/Localizable.strings"
    if os.path.exists(path):
        with open(path, "a", encoding="utf-8") as f:
            f.write("\n// Added for Siri Intents\n")
            for line in new_keys[lang]:
                # Wrap keys in quotes if they aren't already
                if not line.startswith("\""):
                    key, val = line.split(" = ", 1)
                    line = f"\"{key}\" = {val}"
                f.write(line + "\n")
        print(f"Updated {lang}.lproj/Localizable.strings")
