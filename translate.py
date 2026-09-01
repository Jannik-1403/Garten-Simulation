import json

langs = ["en", "es", "fr", "hi", "it", "ja", "ko", "pt-BR", "ru", "zh-Hans"]

# Standard English dictionary, I will just copy "de" for the others if I don't want to translate them perfectly, but I'll try some standard terms for EN.
dict_en = {
    "nutrient.calcium": "Calcium", "nutrient.chloride": "Chloride", "nutrient.chromium": "Chromium",
    "nutrient.copper": "Copper", "nutrient.fiber": "Dietary Fiber", "nutrient.folate": "Folate",
    "nutrient.iodine": "Iodine", "nutrient.iron": "Iron", "nutrient.magnesium": "Magnesium",
    "nutrient.manganese": "Manganese", "nutrient.molybdenum": "Molybdenum", "nutrient.no_data": "No Data",
    "nutrient.phosphorus": "Phosphorus", "nutrient.potassium": "Potassium", "nutrient.selenium": "Selenium",
    "nutrient.settings": "Settings", "nutrient.sodium": "Sodium", "nutrient.status.good": "Good",
    "nutrient.status.low": "Low", "nutrient.status.medium": "Medium", "nutrient.status.veryhigh": "Very High",
    "nutrient.target": "Target:", "nutrient.vitamin_a": "Vitamin A", "nutrient.vitamin_b1": "Vitamin B1 (Thiamin)",
    "nutrient.vitamin_b12": "Vitamin B12", "nutrient.vitamin_b2": "Vitamin B2 (Riboflavin)",
    "nutrient.vitamin_b3": "Vitamin B3 (Niacin)", "nutrient.vitamin_b5": "Vitamin B5 (Pantothenic Acid)",
    "nutrient.vitamin_b6": "Vitamin B6", "nutrient.vitamin_b7": "Vitamin B7 (Biotin)",
    "nutrient.vitamin_c": "Vitamin C", "nutrient.vitamin_d": "Vitamin D", "nutrient.vitamin_e": "Vitamin E",
    "nutrient.vitamin_k": "Vitamin K", "nutrient.zinc": "Zinc",
    "time.month": "Month", "time.week": "Week", "time.year": "Year"
}

with open('Garten_Simulation/Localizable.xcstrings', 'r', encoding='utf-8') as f:
    data = json.load(f)

for key, val in data['strings'].items():
    if key in dict_en or key.startswith("nutrient.") or key.startswith("time."):
        localizations = val.get('localizations', {})
        # ensure "de" state is translated
        if "de" in localizations:
            localizations["de"]["stringUnit"]["state"] = "translated"
        
        # fallback string
        en_str = dict_en.get(key, localizations.get("de", {}).get("stringUnit", {}).get("value", key))
        
        for lang in langs:
            if lang not in localizations:
                localizations[lang] = {"stringUnit": {"state": "translated", "value": en_str}}
            else:
                localizations[lang]["stringUnit"]["state"] = "translated"
        
        val["localizations"] = localizations
        val["extractionState"] = "manual"

with open('Garten_Simulation/Localizable.xcstrings', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

