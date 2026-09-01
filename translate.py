import json

path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"
with open(path, "r") as f:
    data = json.load(f)

new_keys = {
    "health.metric.energy": {
        "de": "Kalorien", "en": "Calories", "fr": "Calories", "es": "Calorías",
        "it": "Calorie", "pt": "Calorias", "pt-BR": "Calorias", "nl": "Calorieën",
        "ru": "Калории", "tr": "Kalori", "pl": "Kalorie", "ja": "カロリー",
        "ko": "칼로리", "zh-Hans": "卡路里", "zh-Hant": "卡路里", "hi": "कैलोरी"
    },
    "health.metric.protein": {
        "de": "Protein", "en": "Protein", "fr": "Protéines", "es": "Proteína",
        "it": "Proteine", "pt": "Proteína", "pt-BR": "Proteína", "nl": "Eiwit",
        "ru": "Белок", "tr": "Protein", "pl": "Białko", "ja": "タンパク質",
        "ko": "단백질", "zh-Hans": "蛋白质", "zh-Hant": "蛋白質", "hi": "प्रोटीन"
    },
    "health.metric.carbs": {
        "de": "Kohlenhydrate", "en": "Carbs", "fr": "Glucides", "es": "Carbohidratos",
        "it": "Carboidrati", "pt": "Carboidratos", "pt-BR": "Carboidratos", "nl": "Koolhydraten",
        "ru": "Углеводы", "tr": "Karbonhidrat", "pl": "Węglowodany", "ja": "炭水化物",
        "ko": "탄수화물", "zh-Hans": "碳水化合物", "zh-Hant": "碳水化合物", "hi": "कार्बोहाइड्रेट"
    },
    "health.metric.fat": {
        "de": "Fette", "en": "Fat", "fr": "Lipides", "es": "Grasas",
        "it": "Grassi", "pt": "Gorduras", "pt-BR": "Gorduras", "nl": "Vetten",
        "ru": "Жиры", "tr": "Yağlar", "pl": "Tłuszcze", "ja": "脂質",
        "ko": "지방", "zh-Hans": "脂肪", "zh-Hant": "脂肪", "hi": "वसा"
    }
}

for key, trans in new_keys.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    
    for lang, val in trans.items():
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }

with open(path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Translations updated with proper languages successfully.")
