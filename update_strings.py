import json
import time
from deep_translator import GoogleTranslator

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

new_keys = {
    "nutrient.settings.dge_info": "Die Ziele basieren auf den Empfehlungen der DGE (Deutsche Gesellschaft für Ernährung).",
    "nutrient.settings": "Einstellungen",
    "nutrient.category.vitamins": "Vitamine",
    "nutrient.category.minerals": "Mineralstoffe",
    "nutrient.category.fiber": "Ballaststoffe",
    "nutrient.target": "Tagesziel:",
    "time.week": "Woche",
    "time.month": "Monat",
    "time.year": "Jahr",
    "nutrient.no_data": "Keine Daten",
    "nutrient.vitamin_c": "Vitamin C",
    "nutrient.vitamin_a": "Vitamin A",
    "nutrient.folate": "Folsäure",
    "nutrient.vitamin_k": "Vitamin K",
    "nutrient.vitamin_b1": "Vitamin B1 (Thiamin)",
    "nutrient.vitamin_b2": "Vitamin B2 (Riboflavin)",
    "nutrient.vitamin_b3": "Vitamin B3 (Niacin)",
    "nutrient.vitamin_b5": "Vitamin B5 (Pantothensäure)",
    "nutrient.vitamin_b6": "Vitamin B6",
    "nutrient.vitamin_b7": "Vitamin B7 (Biotin)",
    "nutrient.vitamin_b12": "Vitamin B12",
    "nutrient.vitamin_d": "Vitamin D",
    "nutrient.vitamin_e": "Vitamin E",
    "nutrient.potassium": "Kalium",
    "nutrient.magnesium": "Magnesium",
    "nutrient.calcium": "Calcium",
    "nutrient.chloride": "Chlorid",
    "nutrient.copper": "Kupfer",
    "nutrient.iodine": "Jod",
    "nutrient.iron": "Eisen",
    "nutrient.manganese": "Mangan",
    "nutrient.molybdenum": "Molybdän",
    "nutrient.phosphorus": "Phosphor",
    "nutrient.selenium": "Selen",
    "nutrient.sodium": "Natrium",
    "nutrient.zinc": "Zink",
    "nutrient.chromium": "Chrom",
    "nutrient.fiber": "Ballaststoffe",
    "nutrient.status.veryhigh": "Sehr hoch",
    "nutrient.status.good": "Gut",
    "nutrient.status.medium": "Mäßig",
    "nutrient.status.low": "Niedrig"
}

for k, v in new_keys.items():
    if k not in data["strings"]:
        data["strings"][k] = {
            "extractionState": "manual",
            "localizations": {
                "de": {
                    "stringUnit": {
                        "state": "translated",
                        "value": v
                    }
                }
            }
        }
    else:
        if "localizations" not in data["strings"][k]:
            data["strings"][k]["localizations"] = {}
        if "de" not in data["strings"][k]["localizations"]:
            data["strings"][k]["localizations"]["de"] = {
                "stringUnit": {
                    "state": "translated",
                    "value": v
                }
            }

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
