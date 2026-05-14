
import os

langs = ["de", "en", "es", "fr", "it", "pt"]
new_strings = {
    "de": [
        "\"Pflanze in \\(.applicationName) erledigt\" = \"Pflanze in \\(.applicationName) erledigt\";",
        "\"\\(.applicationName) Pflanze gießen\" = \"\\(.applicationName) Pflanze gießen\";",
        "\"Gieße meine Pflanze in \\(.applicationName)\" = \"Gieße meine Pflanze in \\(.applicationName)\";",
        "\"Meine Pflanze bei \\(.applicationName) gießen\" = \"Meine Pflanze bei \\(.applicationName) gießen\";",
        "\"In \\(.applicationName) eine Pflanze erledigt\" = \"In \\(.applicationName) eine Pflanze erledigt\";",
        "\"Diese Pflanze in \\(.applicationName)\" = \"Diese Pflanze in \\(.applicationName)\";"
    ],
    "en": [
        "\"Plant in \\(.applicationName) done\" = \"Plant in \\(.applicationName) done\";",
        "\"\\(.applicationName) water plant\" = \"\\(.applicationName) water plant\";",
        "\"Water my plant in \\(.applicationName)\" = \"Water my plant in \\(.applicationName)\";",
        "\"Water my plant with \\(.applicationName)\" = \"Water my plant with \\(.applicationName)\";",
        "\"In \\(.applicationName) a plant done\" = \"In \\(.applicationName) a plant done\";",
        "\"This plant in \\(.applicationName)\" = \"This plant in \\(.applicationName)\";"
    ],
    "es": [
        "\"Planta en \\(.applicationName) hecho\" = \"Planta en \\(.applicationName) hecho\";",
        "\"\\(.applicationName) regar planta\" = \"\\(.applicationName) regar planta\";",
        "\"Riega mi planta en \\(.applicationName)\" = \"Riega mi planta en \\(.applicationName)\";",
        "\"Riega mi planta con \\(.applicationName)\" = \"Riega mi planta con \\(.applicationName)\";",
        "\"En \\(.applicationName) una planta hecho\" = \"En \\(.applicationName) una planta hecho\";",
        "\"Esta planta en \\(.applicationName)\" = \"Esta planta en \\(.applicationName)\";"
    ],
    "fr": [
        "\"Plante dans \\(.applicationName) terminé\" = \"Plante dans \\(.applicationName) terminé\";",
        "\"\\(.applicationName) arrose la plante\" = \"\\(.applicationName) arrose la plante\";",
        "\"Arrose ma plante dans \\(.applicationName)\" = \"Arrose ma plante dans \\(.applicationName)\";",
        "\"Arrose ma plante avec \\(.applicationName)\" = \"Arrose ma plante avec \\(.applicationName)\";",
        "\"Dans \\(.applicationName) une plante terminé\" = \"Dans \\(.applicationName) une plante terminé\";",
        "\"Cette plante dans \\(.applicationName)\" = \"Cette plante dans \\(.applicationName)\";"
    ],
    "it": [
        "\"Pianta in \\(.applicationName) fatto\" = \"Pianta in \\(.applicationName) fatto\";",
        "\"\\(.applicationName) annaffia la pianta\" = \"\\(.applicationName) annaffia la pianta\";",
        "\"Annaffia la mia pianta in \\(.applicationName)\" = \"Annaffia la mia pianta in \\(.applicationName)\";",
        "\"Annaffia la mia pianta con \\(.applicationName)\" = \"Annaffia la mia pianta con \\(.applicationName)\";",
        "\"In \\(.applicationName) una pianta fatto\" = \"In \\(.applicationName) una pianta fatto\";",
        "\"Questa pianta in \\(.applicationName)\" = \"Questa pianta in \\(.applicationName)\";"
    ],
    "pt": [
        "\"Planta no \\(.applicationName) feito\" = \"Planta no \\(.applicationName) feito\";",
        "\"\\(.applicationName) regar planta\" = \"\\(.applicationName) regar planta\";",
        "\"Rega a minha planta no \\(.applicationName)\" = \"Rega a minha planta no \\(.applicationName)\";",
        "\"Rega a minha planta com \\(.applicationName)\" = \"Rega a minha planta com \\(.applicationName)\";",
        "\"No \\(.applicationName) uma planta feito\" = \"No \\(.applicationName) uma planta feito\";",
        "\"Esta planta no \\(.applicationName)\" = \"Esta planta no \\(.applicationName)\";"
    ]
}

for lang in langs:
    path = f"/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/{lang}.lproj/AppShortcuts.strings"
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(new_strings[lang]) + "\n")
    print(f"Updated {lang}.lproj/AppShortcuts.strings")
